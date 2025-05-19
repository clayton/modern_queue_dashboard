# frozen_string_literal: true

module ModernQueueDashboard
  class QueuesController < ApplicationController
    def index
      @queues = QueueSummary.with_stats
    end

    def show
      @queue_name = params[:id]
      @queue = QueueSummary.with_stats.detect { |q| q.name == @queue_name }
      @status = params[:status]

      if @queue
        # Set up pagination with Pagy
        page = params[:page] || 1
        per_page = 50

        if @status.present?
          # Get the accurate count for this status
          @total_count = JobSummary.count_jobs_by_status(@queue_name, @status)

          # Use our specialized method to get jobs with this status
          @jobs_collection, _ = JobSummary.for_queue_with_status(@queue_name, @status, page.to_i, per_page)
          @pagy = Pagy.new(count: @total_count, page: page.to_i, items: per_page)
          @jobs = @jobs_collection
        else
          # When no status filter, use regular pagination
          @total_count = SolidQueue::Job.where(queue_name: @queue_name).count
          @pagy = Pagy.new(count: @total_count, page: page.to_i, items: per_page)
          @jobs = JobSummary.for_queue(@queue_name, per_page)
        end
      else
        flash[:error] = "Queue not found"
        redirect_to queues_path
      end
    end

    def retry_job
      @queue_name = params[:id]
      job_id = params[:job_id]

      # Find the job in the database
      job = SolidQueue::Job.find_by(id: job_id)

      if job
        # Handle retry logic based on job status
        if perform_job_retry(job)
          flash[:notice] = "Job #{job_id} has been requeued for retry"
        else
          flash[:error] = "Unable to retry job #{job_id}"
        end
      else
        flash[:error] = "Job #{job_id} not found"
      end

      redirect_to queue_path(@queue_name)
    end

    def discard_job
      @queue_name = params[:id]
      job_id = params[:job_id]

      # Find the job in the database
      job = SolidQueue::Job.find_by(id: job_id)

      if job
        # Handle discard logic
        if perform_job_discard(job)
          flash[:notice] = "Job #{job_id} has been discarded"
        else
          flash[:error] = "Unable to discard job #{job_id}"
        end
      else
        flash[:error] = "Job #{job_id} not found"
      end

      redirect_to queue_path(@queue_name)
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
        # Log the error for debugging
        Rails.logger.error("Error retrying job #{job.id}: #{e.message}")
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
        # Log the error for debugging
        Rails.logger.error("Error discarding job #{job.id}: #{e.message}")
        return false
      end
    end
  end
end
