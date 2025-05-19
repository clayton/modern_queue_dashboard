require "test_helper"

class ModernQueueDashboardTest < ActionDispatch::IntegrationTest
  test "can access dashboard" do
    get "/queue-dashboard"
    assert_response :success
    assert_select "h1", "Modern Queue Dashboard"

    # Check for metrics and queue table structure
    assert_select "div.grid" # Metric cards container
    assert_select "table" # Queue table
  end

  test "can enqueue and view job in dashboard" do
    # Enqueue a test job
    post jobs_path
    assert_redirected_to root_path
    follow_redirect!
    assert_select "div", /Test job enqueued!/

    # Visit the dashboard to see if the job is listed
    get "/queue-dashboard"
    assert_response :success

    # Our dashboard should have a container
    assert_select "div.container"

    # We should have a table
    assert_select "table"
    assert_select "th", "Queue"
    assert_select "th", "Pending"
  end

  test "can access queue details page" do
    # First visit the dashboard
    get "/queue-dashboard"
    assert_response :success

    # Then visit the queue details page
    get "/queue-dashboard/queues/default"
    assert_response :success

    # Check for queue details structure
    assert_select "h2", /Queue: default/
    assert_select "div.grid" # Stats cards
  end

  test "redirects for nonexistent queue" do
    # Visit a non-existent queue
    get "/queue-dashboard/queues/nonexistent"

    # Should redirect back to queues index
    assert_redirected_to "/queue-dashboard/queues"
  end
end
