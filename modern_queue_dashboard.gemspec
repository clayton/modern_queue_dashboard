# frozen_string_literal: true

require_relative "lib/modern_queue_dashboard/version"

Gem::Specification.new do |spec|
  spec.name = "modern_queue_dashboard"
  spec.version = ModernQueueDashboard::VERSION
  spec.authors = [ "Clayton Lengel-Zigich" ]
  spec.email = [ "6334+clayton@users.noreply.github.com" ]

  spec.summary = "Dashboard for Rails Solid Queue jobs"
  spec.description = "Mountable Hotwire/Tailwind dashboard engine that visualizes Solid Queue job queues and metrics."
  spec.homepage = "https://github.com/clayton/modern_queue_dashboard"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.8"

  # No private gem server – publish to RubyGems by default

  spec.metadata["homepage_uri"] = "https://github.com/clayton/modern_queue_dashboard"
  spec.metadata["source_code_uri"] = "https://github.com/clayton/modern_queue_dashboard/tree/main"
  spec.metadata["documentation_uri"] = "https://github.com/clayton/modern_queue_dashboard#readme"
  spec.metadata["changelog_uri"] = "https://github.com/clayton/modern_queue_dashboard/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile node_modules/]) ||
        f.include?("node_modules")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "rails", "~> 8.0", ">= 8.0.0"
  spec.add_dependency "solid_queue", "~> 1.1"
  spec.add_dependency "tailwindcss-rails", "~> 2.0"
  spec.add_dependency "turbo-rails", "~> 1.5"

  # Development dependencies
  spec.add_development_dependency "minitest", "~> 5.18"
  spec.add_development_dependency "minitest-reporters", "~> 1.6"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rails-omakase", "~> 1.0"
end
