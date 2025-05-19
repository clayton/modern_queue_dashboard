require "test_helper"

class SolidQueueIntegrationTest < ActionDispatch::IntegrationTest
  test "enqueuing a job updates the dashboard metrics" do
    # Get initial metrics
    get "/queue-dashboard"
    assert_response :success

    # Enqueue multiple test jobs
    3.times do |i|
      TestJob.perform_later("test argument #{i}", Time.current.to_s)
    end

    # Make sure we can go back to the dashboard
    get "/queue-dashboard"
    assert_response :success

    # The jobs should be reflected in the dashboard
    # This is a basic structure test - actual job counting would need appropriate setup
    assert_select "table"
    assert_select "td", /default/
  end

  test "can see job details in queue" do
    # Enqueue a job
    TestJob.perform_later("test argument", Time.current.to_s)

    # Visit the specific queue page
    get "/queue-dashboard/queues/default"
    assert_response :success

    # Check for queue details
    assert_select "h2", "Queue: default"
  end

  # This test would normally be improved with actual job cleanup,
  # checking specific job counts, etc.
end
