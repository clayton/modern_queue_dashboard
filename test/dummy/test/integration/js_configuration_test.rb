require "test_helper"

class JsConfigurationTest < ActionDispatch::IntegrationTest
  test "dashboard includes refresh interval data attribute" do
    # Set a custom refresh interval
    original_config = ModernQueueDashboard.configuration.dup

    ModernQueueDashboard.configure do |config|
      config.refresh_interval = 10
    end

    # Visit the dashboard
    get "/queue-dashboard"
    assert_response :success

    # Check that the data attribute is set correctly
    assert_select "div.modern-queue-dashboard[data-refresh-interval='10']"

    # Check that the info text shows the correct value
    assert_select "div.text-sm", /Refresh interval: 10 seconds/

    # Reset config
    ModernQueueDashboard.configuration = original_config
  end
end
