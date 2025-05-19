# frozen_string_literal: true

require_relative "test_helper"

class QueueSummaryTest < Minitest::Test
  def test_with_stats_returns_queue_stat_collection
    result = ModernQueueDashboard::QueueSummary.with_stats
    assert_kind_of ModernQueueDashboard::QueueStatCollection, result
    assert_kind_of Enumerable, result # Should be enumerable
  end

  def test_queue_stat_struct
    stat = ModernQueueDashboard::QueueStat.new(name: "default", pending: 0, scheduled: 0, running: 0, failed: 0,
                                               latency: 0)
    assert_equal "default", stat.name
    assert_equal 0, stat.pending
  end

  def test_queue_stat_collection_supports_limit
    result = ModernQueueDashboard::QueueSummary.with_stats
    limited = result.limit(5)
    assert_kind_of ModernQueueDashboard::QueueStatCollection, limited
  end
end
