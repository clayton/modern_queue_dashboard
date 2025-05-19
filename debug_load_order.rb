#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'

puts "Loading files..."
require_relative 'lib/modern_queue_dashboard'
require_relative 'app/models/modern_queue_dashboard/queue_summary'

# Check if constants are loaded
puts "ModernQueueDashboard defined? #{defined?(ModernQueueDashboard) != nil}"
puts "QueueSummary defined? #{defined?(ModernQueueDashboard::QueueSummary) != nil}"
puts "QueueStatCollection defined? #{defined?(ModernQueueDashboard::QueueStatCollection) != nil}"

if defined?(ModernQueueDashboard::QueueSummary)
  puts "ModernQueueDashboard::QueueSummary location: #{ModernQueueDashboard::QueueSummary.method(:with_stats).source_location}"
end
