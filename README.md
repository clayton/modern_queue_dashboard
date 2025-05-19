# Modern Queue Dashboard

A mountable Rails engine that provides a clean dashboard **specifically designed for monitoring [Solid Queue](https://github.com/basecamp/solid_queue)** jobs. Built with Tailwind CSS, Turbo frames, and Stimulus controllers.

![Dashboard Screenshot](screenshots/dashboard.png)

## Why the "Modern Queue Dashboard"?

I didn't want to give the impression that there is any association with Solid Queue and because this dashboard could be used with other job backends in the future.

## Features

* High-level metrics - counts for pending, scheduled, running, completed and failed jobs
* Per-queue statistics - job counts and latency metrics
* Job details - arguments, timestamps, state transitions, and error information
* Real-time updates - auto-refreshing metrics via Turbo Stream polling
* Clean UI - responsive interface using Tailwind CSS
* Zero setup - install, mount, and go

## Requirements

* Rails 8.0+
* Ruby 3.3.8+
* **Solid Queue 1.1+** (this dashboard is exclusively for Solid Queue and does not support other job backends)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "modern_queue_dashboard"
```

And then execute:

```bash
bundle install
```

## Mounting the Dashboard

Add the following to your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # ... your other routes

  # Mount the dashboard at /queue-dashboard
  mount ModernQueueDashboard::Engine, at: "/queue-dashboard"
end
```

## Security

The dashboard doesn't include authentication by itself. You should restrict access using your application's authentication system.

### With Devise

```ruby
# In config/routes.rb
authenticate :user, -> { current_user.admin? } do
  mount ModernQueueDashboard::Engine, at: "/queue-dashboard"
end
```

### With Basic Auth

```ruby
# In config/routes.rb
require "authenticated_constraint"

constraints AuthenticatedConstraint.new do
  mount ModernQueueDashboard::Engine, at: "/queue-dashboard"
end

# In lib/authenticated_constraint.rb
class AuthenticatedConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find_by(id: request.session[:user_id])
    user && user.admin?
  end
end
```

## Configuration

You can configure the dashboard by creating an initializer:

```ruby
# config/initializers/modern_queue_dashboard.rb
ModernQueueDashboard.configure do |config|
  config.refresh_interval = 5 # seconds
  config.time_zone = "UTC"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run the following:

```bash
# Run unit tests
bundle exec rake unit_tests

# Run unit tests + RuboCop style checks
bundle exec rake ci

# Run just RuboCop
bundle exec rubocop
```

### Building Tailwind CSS

The dashboard uses Tailwind CSS for styling. When making changes to the styles, you need to rebuild the CSS file:

```bash
# Install Node.js dependencies (only needed once)
npm install -D tailwindcss

# Build the CSS file
bin/build
```

This will process the Tailwind directives in `app/assets/stylesheets/modern_queue_dashboard.css` and output the compiled CSS to `app/assets/builds/modern_queue_dashboard.css`.

### Dummy Application

The gem includes a dummy Rails application in `test/dummy` for integration testing and development:

```bash
# Start the dummy app server
cd test/dummy
bin/rails server

# Start the solid_queue worker
cd test/dummy
bin/rails solid_queue:process
```

Then visit http://localhost:3000 and navigate to http://localhost:3000/queue-dashboard to see the dashboard.

### CI Process

The CI pipeline runs on GitHub Actions and includes:
- Unit tests for the gem
- RuboCop style checks using the Rails Omakase style guide
- (Optional) Integration tests with the dummy application

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clayton/modern_queue_dashboard. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/clayton/modern_queue_dashboard/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Modern Queue Dashboard project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/clayton/modern_queue_dashboard/blob/main/CODE_OF_CONDUCT.md).
