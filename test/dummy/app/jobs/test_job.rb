class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Simulate longer work
    sleep_time = 15
    Rails.logger.info "TestJob starting, will sleep for #{sleep_time} seconds"
    
    sleep sleep_time
    
    Rails.logger.info "TestJob completed with args: #{args.inspect}"
  end
end
