# frozen_string_literal: true

module ModernQueueDashboard
  class DashboardController < ApplicationController
    def index
      @metrics = Metrics.summary
      @queues  = QueueSummary.with_stats.limit(10)
    end
  end
end
