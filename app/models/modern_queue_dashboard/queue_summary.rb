# frozen_string_literal: true

module ModernQueueDashboard
  QueueStat = Struct.new(:name, :pending, :scheduled, :running, :failed, :latency, keyword_init: true)

  class QueueSummary
    class << self
      def with_stats
        queue_names.map { |q| stats_for(q) }.sort_by(&:name)
      end

      private

      def queue_names
        SolidQueue::Job.distinct.pluck(:queue_name)
      end

      def stats_for(name)
        pending   = SolidQueue::Job.where(queue_name: name).where("run_at <= ?", Time.current).count
        scheduled = SolidQueue::Job.where(queue_name: name).where("run_at > ?", Time.current).count
        running   = SolidQueue::Execution.where(queue_name: name, finished_at: nil).count if execution_has_queue_name?
        running ||= 0
        failed    = SolidQueue::FailedExecution.where(queue_name: name).count if failed_has_queue_name?
        failed  ||= 0

        oldest_run_at = SolidQueue::Job.where(queue_name: name).order(:run_at).limit(1).pick(:run_at)
        latency       = oldest_run_at ? (Time.current - oldest_run_at).to_i : 0

        QueueStat.new(name:, pending:, scheduled:, running:, failed:, latency:)
      end

      def execution_has_queue_name?
        SolidQueue::Execution.column_names.include?("queue_name")
      end

      def failed_has_queue_name?
        SolidQueue::FailedExecution.column_names.include?("queue_name")
      end
    end
  end
end
