# frozen_string_literal: true

require_relative "test_helper"

class QueueSummaryTest < Minitest::Test
  def test_with_stats_returns_array
    result = ModernQueueDashboard::QueueSummary.with_stats
    assert_kind_of Array, result
  end

  def test_queue_stat_struct
    stat = ModernQueueDashboard::QueueStat.new(name: "default", pending: 0, scheduled: 0, running: 0, failed: 0,
                                               latency: 0)
    assert_equal "default", stat.name
    assert_equal 0, stat.pending
  end
end
