# frozen_string_literal: true

require_relative "test_helper"

class MetricsTest < Minitest::Test
  def test_summary_returns_six_metrics
    metrics = ModernQueueDashboard::Metrics.summary

    assert_equal 6, metrics.size
    keys = metrics.map(&:key)
    expected_keys = %i[pending scheduled running failed completed latency]
    assert_equal expected_keys.sort, keys.sort
  end

  def test_metrics_struct_has_attributes
    metric = ModernQueueDashboard::Metric.new(key: :pending, label: "Pending", value: 0)

    assert_equal :pending, metric.key
    assert_equal "Pending", metric.label
    assert_equal 0, metric.value
  end
end
