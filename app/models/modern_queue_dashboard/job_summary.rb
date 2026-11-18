# frozen_string_literal: true

module ModernQueueDashboard
  JobStat = Struct.new(:id, :class_name, :queue_name, :arguments, :created_at, :status, :error, :exception_class, :backtrace, :finished_at, keyword_init: true)

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

      def for_queue_with_status(queue_name, status, page = 1, items = 50)
        return JobStatCollection.new([]) if test_environment?

        # Base query for jobs in this queue
        base_query = SolidQueue::Job.where(queue_name: queue_name)

        # First, determine how to filter by status
        if status.present?
          # Pre-filter records based on status to get accurate counts
          case status.to_s
          when "completed"
            jobs = base_query.where.not(finished_at: nil)
            filtered_count = jobs.count
          when "failed"
            # Get job IDs that have failed executions
            failed_job_ids = SolidQueue::FailedExecution.pluck(:job_id)
            jobs = base_query.where(id: failed_job_ids)
            filtered_count = jobs.count
          when "running"
            # Get job IDs that have claimed executions
            running_job_ids = SolidQueue::ClaimedExecution.pluck(:job_id)
            jobs = base_query.where(id: running_job_ids)
            filtered_count = jobs.count
          when "scheduled"
            # Get job IDs that have scheduled executions
            scheduled_job_ids = SolidQueue::ScheduledExecution.pluck(:job_id)
            jobs = base_query.where(id: scheduled_job_ids)
            filtered_count = jobs.count
          when "pending"
            # Get job IDs that have ready executions
            pending_job_ids = SolidQueue::ReadyExecution.pluck(:job_id)
            jobs = base_query.where(id: pending_job_ids)
            filtered_count = jobs.count
          else
            # Unknown status - return all jobs but will be filtered later
            jobs = base_query
            filtered_count = jobs.count
          end
        else
          # No status filter - use all jobs
          jobs = base_query
          filtered_count = jobs.count
        end

        # Apply pagination
        offset = (page - 1) * items
        paginated_jobs = jobs.order(created_at: :desc).offset(offset).limit(items)

        # Convert to JobStat objects
        job_stats = paginated_jobs.map { |job| job_to_stat(job) }

        # Double-check status if we couldn't pre-filter accurately
        if status.present? && status.to_s != "completed" && status.to_s != "unknown"
          # For statuses that might need more accurate filtering (though we pre-filtered above)
          job_stats = job_stats.select { |job| job.status == status.to_s }
        end

        # Return collection and filtered count for pagination
        [ JobStatCollection.new(job_stats), filtered_count ]
      end

      def all_jobs(limit = 50)
        return JobStatCollection.new([]) if test_environment?

        # Get all jobs, ordered by most recently created
        jobs = SolidQueue::Job.order(created_at: :desc)
                              .limit(limit)
                              .map { |job| job_to_stat(job) }

        JobStatCollection.new(jobs)
      end

      def count_jobs_by_status(queue_name, status)
        return 0 if test_environment?

        base_query = SolidQueue::Job.where(queue_name: queue_name)

        case status.to_s
        when "completed"
          base_query.where.not(finished_at: nil).count
        when "failed"
          failed_job_ids = SolidQueue::FailedExecution.pluck(:job_id)
          base_query.where(id: failed_job_ids).count
        when "running"
          running_job_ids = SolidQueue::ClaimedExecution.pluck(:job_id)
          base_query.where(id: running_job_ids).count
        when "scheduled"
          scheduled_job_ids = SolidQueue::ScheduledExecution.pluck(:job_id)
          base_query.where(id: scheduled_job_ids).count
        when "pending"
          pending_job_ids = SolidQueue::ReadyExecution.pluck(:job_id)
          base_query.where(id: pending_job_ids).count
        else
          base_query.count
        end
      end

      def job_details(job)
        # This method returns a single JobStat object with all details for a specific job
        return nil unless job

        # Get detailed information about the job
        job_stat = job_to_stat(job)

        # Add additional details you might want to include in the job details page
        # For example, you could add execution history, timing information, etc.

        job_stat
      end

      private

      def job_to_stat(job)
        # Determine job status
        status = determine_status(job)

        # Get error data if job failed
        error = nil
        exception_class = nil
        backtrace = nil
        raw_error = nil

        if status == "failed"
          failed_execution = SolidQueue::FailedExecution.find_by(job_id: job.id)
          if failed_execution&.error.present?
            # Store the raw error for display
            raw_error = failed_execution.error
          end
        end

        # Parse arguments - handle cases with no arguments properly
        arguments_display = if job.arguments.nil? || !job.arguments.is_a?(String) || job.arguments.empty? || (job.arguments.is_a?(String) && job.arguments.strip == "")
                              "None"
        else
                              begin
                                # Try to parse as JSON first
                                arguments_data = JSON.parse(job.arguments)
                                format_arguments(arguments_data)
                              rescue JSON::ParserError
                                # If we can't parse as JSON, show as is but check if it's meaningful
                                raw_value = job.arguments.to_s.strip
                                raw_value.present? ? raw_value : "None"
                              end
        end

        # Create job stat with the raw error data
        JobStat.new(
          id: job.id,
          class_name: job.class_name,
          queue_name: job.queue_name,
          arguments: arguments_display,
          created_at: job.created_at,
          finished_at: job.finished_at,
          status: status,
          error: raw_error,
          exception_class: nil,
          backtrace: nil
        )
      rescue => e
        # Only show parsing error if there were actually arguments to parse
        arg_display = if job.arguments.present? && job.arguments.is_a?(String) && job.arguments.strip != ""
                        "Error parsing arguments"
        else
                        "None"
        end

        JobStat.new(
          id: job.id,
          class_name: job.class_name,
          queue_name: job.queue_name,
          arguments: arg_display,
          created_at: job.created_at,
          status: status,
          error: e.message,
          exception_class: nil,
          backtrace: nil
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

        if args.is_a?(Array)
          if args.empty?
            "None"
          else
            # Truncate long arguments to prevent display issues
            args.map do |arg|
              if arg.nil?
                "nil"
              elsif arg.is_a?(String) && arg.length > 100
                arg[0..100] + "..."
              else
                arg.to_s
              end
            end.join(", ")
          end
        elsif args.is_a?(Hash)
          if args.empty?
            "None"
          else
            # Format hash in a more readable way
            args.map do |k, v|
              v_str = v.to_s
              value = v_str.length > 50 ? "#{v_str[0..50]}..." : v_str
              "#{k}: #{value}"
            end.join(", ")
          end
        else
          # For other types, just convert to string
          str = args.to_s
          str.present? ? str : "None"
        end
      end

      def test_environment?
        ENV["RAILS_ENV"] == "test" || ENV["RACK_ENV"] == "test"
      end
    end
  end
end
