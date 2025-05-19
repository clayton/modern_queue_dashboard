require "test_helper"

class ConfigurationTest < ActionDispatch::IntegrationTest
  test "default configuration values" do
    # Reset configuration to defaults
    ModernQueueDashboard.configuration = ModernQueueDashboard::Configuration.new

    # Check default values
    assert_equal 5, ModernQueueDashboard.configuration.refresh_interval
    assert_equal "UTC", ModernQueueDashboard.configuration.time_zone
  end

  test "configuration can be updated" do
    # Configure the gem with custom values
    original_config = ModernQueueDashboard.configuration.dup

    ModernQueueDashboard.configure do |config|
      config.refresh_interval = 10
      config.time_zone = "Eastern Time (US & Canada)"
    end

    # Check that the values were updated
    assert_equal 10, ModernQueueDashboard.configuration.refresh_interval
    assert_equal "Eastern Time (US & Canada)", ModernQueueDashboard.configuration.time_zone

    # Reset for other tests
    ModernQueueDashboard.configuration = original_config
  end
end
