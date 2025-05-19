# frozen_string_literal: true

module ModernQueueDashboard
  JobStat = Struct.new(:id, :class_name, :queue_name, :arguments, :created_at, :status, :error, keyword_init: true)

  # Collection class for JobStat objects
  class JobStatCollection
    include Enumerable

    def initialize(stats)
      @stats = stats
    end

    def each(&block)
      @stats.each(&block)
    end

    def limit(num)
      JobStatCollection.new(@stats.take(num))
    end
  end

  class JobSummary
    class << self
      def for_queue(queue_name, limit = 50)
        return JobStatCollection.new([]) if test_environment?

        # Get jobs from SolidQueue::Job, ordered by most recently created
        jobs = SolidQueue::Job.where(queue_name: queue_name)
                              .order(created_at: :desc)
                              .limit(limit)
                              .map { |job| job_to_stat(job) }

        JobStatCollection.new(jobs)
      end

      def all_jobs(limit = 50)
        return JobStatCollection.new([]) if test_environment?

        # Get all jobs, ordered by most recently created
        jobs = SolidQueue::Job.order(created_at: :desc)
                              .limit(limit)
                              .map { |job| job_to_stat(job) }

        JobStatCollection.new(jobs)
      end

      private

      def job_to_stat(job)
        # Determine job status
        status = determine_status(job)

        # Get error message if job failed
        error = nil
        if status == "failed"
          failed_execution = SolidQueue::FailedExecution.find_by(job_id: job.id)
          error = failed_execution&.error
        end

        # Parse arguments - handle cases with no arguments properly
        arguments_display = if job.arguments.nil? || job.arguments.empty?
                           "None"
        else
                           begin
                             arguments_data = JSON.parse(job.arguments)
                             format_arguments(arguments_data)
                           rescue JSON::ParserError
                             # If we can't parse as JSON, show as is
                             job.arguments.to_s
                           end
        end

        # Create job stat
        JobStat.new(
          id: job.id,
          class_name: job.class_name,
          queue_name: job.queue_name,
          arguments: arguments_display,
          created_at: job.created_at,
          status: status,
          error: error
        )
      rescue => e
        # Handle any parsing errors
        JobStat.new(
          id: job.id,
          class_name: job.class_name,
          queue_name: job.queue_name,
          arguments: "Error parsing arguments",
          created_at: job.created_at,
          status: status,
          error: error || e.message
        )
      end

      def determine_status(job)
        if job.finished_at.present?
          "completed"
        elsif SolidQueue::FailedExecution.exists?(job_id: job.id)
          "failed"
        elsif SolidQueue::ClaimedExecution.exists?(job_id: job.id)
          "running"
        elsif SolidQueue::ScheduledExecution.exists?(job_id: job.id)
          "scheduled"
        elsif SolidQueue::ReadyExecution.exists?(job_id: job.id)
          "pending"
        else
          "unknown"
        end
      end

      def format_arguments(args)
        return "None" if args.blank?

        if args.is_a?(Array) && args.length > 0
          # Truncate long arguments to prevent display issues
          args.map do |arg|
            if arg.is_a?(String) && arg.length > 100
              arg[0..100] + "..."
            else
              arg.to_s
            end
          end.join(", ")
        else
          args.to_s
        end
      end

      def test_environment?
        ENV["RAILS_ENV"] == "test" || ENV["RACK_ENV"] == "test"
      end
    end
  end
end
