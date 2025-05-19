# frozen_string_literal: true

module ModernQueueDashboard
  class DashboardController < ApplicationController
    def index
      @metrics = Metrics.summary
      @queues  = QueueSummary.with_stats.limit(10)
      @recent_jobs = JobSummary.all_jobs(10)  # Show 10 most recent jobs across all queues
    end
  end
end
