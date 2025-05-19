# frozen_string_literal: true

module ModernQueueDashboard
  Metric = Struct.new(:key, :label, :value, keyword_init: true)

  class Metrics
    class << self
      def summary
        metrics = [
          Metric.new(key: :pending,   label: "Pending",   value: pending_count),
          Metric.new(key: :scheduled, label: "Scheduled", value: scheduled_count),
          Metric.new(key: :running,   label: "Running",   value: running_count),
          Metric.new(key: :failed,    label: "Failed",    value: failed_count),
          Metric.new(key: :completed, label: "Completed", value: completed_count),
          Metric.new(key: :latency,   label: "Latency",   value: latency_seconds)
        ]
        metrics
      end

      private

      def pending_count
        begin
          count = SolidQueue::ReadyExecution.count
          count
        rescue
          0
        end
      end

      def scheduled_count
        begin
          count = SolidQueue::ScheduledExecution.count
          count
        rescue
          0
        end
      end

      def running_count
        begin
          count = SolidQueue::ClaimedExecution.count
          count
        rescue
          0
        end
      end

      def failed_count
        begin
          count = SolidQueue::FailedExecution.count
          count
        rescue
          0
        end
      end

      def completed_count
        begin
          count = SolidQueue::Job.where.not(finished_at: nil).count
          count
        rescue
          0
        end
      end

      def latency_seconds
        begin
          oldest = SolidQueue::ReadyExecution
            .joins("INNER JOIN solid_queue_jobs ON solid_queue_jobs.id = solid_queue_ready_executions.job_id")
            .order("solid_queue_ready_executions.created_at")
            .limit(1)
            .pick("solid_queue_jobs.created_at")

          latency = oldest ? (Time.now - oldest).to_i : 0
          latency
        rescue
          0
        end
      end
    end
  end
end
