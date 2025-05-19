# frozen_string_literal: true

module ModernQueueDashboard
  QueueStat = Struct.new(:name, :pending, :scheduled, :running, :failed, :latency, keyword_init: true)

  # Collection class for QueueStat objects
  class QueueStatCollection
    include Enumerable

    def initialize(stats)
      @stats = stats
    end

    def each(&block)
      @stats.each(&block)
    end

    def limit(num)
      QueueStatCollection.new(@stats.take(num))
    end
  end

  class QueueSummary
    class << self
      def with_stats
        return QueueStatCollection.new([]) if test_environment?

        # Get all unique queue names from Solid Queue jobs
        base_names = SolidQueue::Job.distinct.pluck(:queue_name)

        # Also check execution tables in case job records were deleted but executions remain
        ready_names = SolidQueue::ReadyExecution.distinct.pluck(:queue_name)
        scheduled_names = SolidQueue::ScheduledExecution.distinct.pluck(:queue_name)

        # Combine all queue names
        names = (base_names + ready_names + scheduled_names).uniq

        # Ensure we always have at least the default queue
        names = [ "default" ] if names.empty?

        stats = names.map { |q| stats_for(q) }.sort_by(&:name)
        QueueStatCollection.new(stats)
      end

      private

      def queue_names
        # This is now handled in with_stats
        names = SolidQueue::Job.distinct.pluck(:queue_name)
        names = [ "default" ] if names.empty?
        names
      end

      def stats_for(name)
        # Pending: Jobs in ready_executions table
        pending = begin
          SolidQueue::ReadyExecution.where(queue_name: name).count
        rescue
          0
        end

        # Scheduled: Jobs in scheduled_executions table
        scheduled = begin
          SolidQueue::ScheduledExecution.where(queue_name: name).count
        rescue
          0
        end

        # Running: Jobs in claimed_executions joined with jobs
        running = begin
          SolidQueue::ClaimedExecution
            .joins("INNER JOIN solid_queue_jobs ON solid_queue_jobs.id = solid_queue_claimed_executions.job_id")
            .where("solid_queue_jobs.queue_name = ?", name)
            .count
        rescue
          0
        end

        # Failed: Jobs with failed executions
        failed = begin
          SolidQueue::FailedExecution
            .joins("INNER JOIN solid_queue_jobs ON solid_queue_jobs.id = solid_queue_failed_executions.job_id")
            .where("solid_queue_jobs.queue_name = ?", name)
            .count
        rescue
          0
        end

        # Latency: Time since oldest job in ready_executions was created
        oldest_ready_job = begin
          SolidQueue::ReadyExecution
            .joins("INNER JOIN solid_queue_jobs ON solid_queue_jobs.id = solid_queue_ready_executions.job_id")
            .where("solid_queue_ready_executions.queue_name = ?", name)
            .order("solid_queue_ready_executions.created_at")
            .limit(1)
            .pick("solid_queue_jobs.created_at")
        rescue
          nil
        end

        latency = oldest_ready_job ? (Time.now - oldest_ready_job).to_i : 0

        QueueStat.new(name:, pending:, scheduled:, running:, failed:, latency:)
      end

      def test_environment?
        ENV["RAILS_ENV"] == "test" || ENV["RACK_ENV"] == "test"
      end
    end
  end
end
