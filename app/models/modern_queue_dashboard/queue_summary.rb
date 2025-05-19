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
        # Pending: Jobs scheduled for now or in the past but not finished
        pending = SolidQueue::Job.where(queue_name: name)
                                .where("scheduled_at <= ? AND finished_at IS NULL", Time.current)
                                .count

        # Scheduled: Jobs scheduled for the future
        scheduled = SolidQueue::Job.where(queue_name: name)
                                  .where("scheduled_at > ? AND finished_at IS NULL", Time.current)
                                  .count

        # Running: Jobs that are currently claimed but not finished
        running = SolidQueue::ClaimedExecution.joins("INNER JOIN solid_queue_jobs ON solid_queue_jobs.id = solid_queue_claimed_executions.job_id")
                                            .where("solid_queue_jobs.queue_name = ?", name)
                                            .count

        # Failed: Jobs that have failed executions
        failed = SolidQueue::FailedExecution.joins("INNER JOIN solid_queue_jobs ON solid_queue_jobs.id = solid_queue_failed_executions.job_id")
                                          .where("solid_queue_jobs.queue_name = ?", name)
                                          .count

        # Latency: Time since oldest unfinished job was scheduled
        oldest_scheduled_at = SolidQueue::Job.where(queue_name: name)
                                           .where(finished_at: nil)
                                           .order(:scheduled_at)
                                           .limit(1)
                                           .pick(:scheduled_at)

        latency = oldest_scheduled_at ? (Time.current - oldest_scheduled_at).to_i : 0

        QueueStat.new(name:, pending:, scheduled:, running:, failed:, latency:)
      end
    end
  end
end
