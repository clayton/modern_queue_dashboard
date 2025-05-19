# frozen_string_literal: true

module ModernQueueDashboard
  class QueuesController < ApplicationController
    def index
      @queues = QueueSummary.with_stats
    end

    def show
      @queue_name = params[:id]
      @queue = QueueSummary.with_stats.detect { |q| q.name == @queue_name }

      if @queue
        @jobs = JobSummary.for_queue(@queue_name, 50)
      else
        flash[:error] = "Queue not found"
        redirect_to queues_path
      end
    end
  end
end
