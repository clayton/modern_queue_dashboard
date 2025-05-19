class JobsController < ApplicationController
  def create
    count = params[:count].to_i || 5
    count = 5 if count <= 0 || count > 20
    
    Rails.logger.info "Enqueuing #{count} test jobs..."
    
    count.times do |i|
      # Stagger jobs by 2 seconds each
      if params[:stagger].present?
        TestJob.set(wait: i * 2.seconds).perform_later("test argument #{i}", Time.current.to_s)
        Rails.logger.info "Enqueued job #{i} with 2 second stagger"
      else
        TestJob.perform_later("test argument #{i}", Time.current.to_s)
        Rails.logger.info "Enqueued job #{i} immediately"
      end
    end

    redirect_to root_path, notice: "#{count} test jobs enqueued!"
  end
  
  def debug
    @debug = {}
    
    # Check SolidQueue tables
    @debug[:job_count] = SolidQueue::Job.count
    @debug[:sample_jobs] = SolidQueue::Job.order(created_at: :desc).limit(5).as_json
    
    # Check execution tables
    @debug[:ready_executions] = SolidQueue::ReadyExecution.count
    @debug[:scheduled_executions] = SolidQueue::ScheduledExecution.count
    @debug[:claimed_executions] = SolidQueue::ClaimedExecution.count
    @debug[:failed_executions] = SolidQueue::FailedExecution.count
    
    # Get sample ready executions
    if SolidQueue::ReadyExecution.any?
      @debug[:sample_ready] = SolidQueue::ReadyExecution.limit(3).as_json
    end
    
    # Check for connections between jobs and executions
    if SolidQueue::Job.any? && SolidQueue::ReadyExecution.any?
      job = SolidQueue::Job.first
      @debug[:job_has_execution] = SolidQueue::ReadyExecution.exists?(job_id: job.id)
    end
    
    render json: @debug
  end
end
