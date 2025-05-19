class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Simulate some work
    sleep 1
    puts "Job performed with args: #{args.inspect}"
  end
end
