# frozen_string_literal: true

module ModernQueueDashboard
  QueueStat = Struct.new(:name, :pending, :scheduled, :running, :failed, :latency, keyword_init: true)

  class QueueSummary
    def self.with_stats
      # This is a placeholder and will need actual implementation using SolidQueue
      results = [
        QueueStat.new(
          name: "default",
          pending: 0,
          scheduled: 0,
          running: 0,
          failed: 0,
          latency: 0
        )
      ]
      QueueStatCollection.new(results)
    end
  end

  class QueueStatCollection
    include Enumerable

    def initialize(stats)
      @stats = stats
    end

    def each(&)
      @stats.each(&)
    end

    def limit(num)
      QueueStatCollection.new(@stats.take(num))
    end
  end
end
