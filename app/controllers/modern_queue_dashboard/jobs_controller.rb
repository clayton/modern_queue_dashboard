# frozen_string_literal: true

module ModernQueueDashboard
  class JobsController < ApplicationController
    def show
      @job_id = params[:id]
      job = SolidQueue::Job.find_by(id: @job_id)

      if job
        # Check if this is a failed job and get error details
        if SolidQueue::FailedExecution.exists?(job_id: job.id)
          @failed_execution = SolidQueue::FailedExecution.find_by(job_id: job.id)

          # Make the raw error string available to the view
          @raw_error = @failed_execution.error if @failed_execution&.error.present?
        end

        @job_stat = JobSummary.job_details(job)
        @queue_name = job.queue_name
      else
        flash[:error] = "Job not found"
        redirect_to root_path
      end
    end

    def retry
      @job_id = params[:id]
      job = SolidQueue::Job.find_by(id: @job_id)

      if job
        # Use the same job retry logic from queues controller
        if perform_job_retry(job)
          flash[:notice] = "Job #{@job_id} has been requeued for retry"
        else
          flash[:error] = "Unable to retry job #{@job_id}"
        end
      else
        flash[:error] = "Job #{@job_id} not found"
      end

      redirect_to job_path(@job_id)
    end

    def discard
      @job_id = params[:id]
      job = SolidQueue::Job.find_by(id: @job_id)

      if job
        # Use the same job discard logic from queues controller
        if perform_job_discard(job)
          flash[:notice] = "Job #{@job_id} has been discarded"
        else
          flash[:error] = "Unable to discard job #{@job_id}"
        end
      else
        flash[:error] = "Job #{@job_id} not found"
      end

      redirect_to job_path(@job_id)
    end

    private

    def perform_job_retry(job)
      ActiveRecord::Base.transaction do
        # Remove the job from failed executions if it failed
        SolidQueue::FailedExecution.where(job_id: job.id).delete_all

        # Check if the job is in any execution table and handle accordingly
        case
        when SolidQueue::ClaimedExecution.exists?(job_id: job.id)
          # Running job - can't retry while running
          return false
        when SolidQueue::ScheduledExecution.exists?(job_id: job.id)
          # If scheduled, we'll just reschedule it to run immediately
          SolidQueue::ScheduledExecution.where(job_id: job.id).delete_all
        end

        # Re-create a ReadyExecution for the job to make it pending again
        SolidQueue::ReadyExecution.create!(
          job_id: job.id,
          queue_name: job.queue_name,
          priority: job.priority || 0
        )

        # Reset the job's finished_at to allow it to run again
        job.update!(finished_at: nil)

        return true
      rescue => e
        # Failed to retry job
        return false
      end
    end

    def perform_job_discard(job)
      ActiveRecord::Base.transaction do
        # Remove from all execution tables
        SolidQueue::FailedExecution.where(job_id: job.id).delete_all
        SolidQueue::ReadyExecution.where(job_id: job.id).delete_all
        SolidQueue::ScheduledExecution.where(job_id: job.id).delete_all
        SolidQueue::ClaimedExecution.where(job_id: job.id).delete_all

        # Mark job as completed (discarded)
        job.update!(finished_at: Time.current)

        return true
      rescue => e
        # Failed to discard job
        return false
      end
    end
  end
end
