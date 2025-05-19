# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

# Main test task for gem's unit tests
Rake::TestTask.new(:unit_tests) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"].exclude("test/dummy/**/*_test.rb")
end

# Simple task that runs everything in sequence
desc "Run all tests and quality checks"
task :ci do
  failed = false

  # Run unit tests
  puts "\n== Running unit tests =="
  Rake::Task["unit_tests"].invoke

  # Run dummy app tests if they exist, but don't fail the build if they fail
  if File.directory?("test/dummy/test/integration")
    puts "\n== Running integration tests (optional) =="
    unless system("cd test/dummy && bin/rails test test/integration 2>/dev/null")
      puts "Integration tests failed or could not run. This is allowed in CI."
    end
  end

  # Always run Rubocop and fail the build if there are issues
  puts "\n== Running RuboCop (Rails Omakase style) =="
  unless system("bundle exec rubocop")
    puts "\nRuboCop found issues - failing the build"
    failed = true
  end

  # Fail the build if any step failed
  fail "CI task failed" if failed
end

# More strict version for CI environments
desc "Run all tests and quality checks strictly (for CI)"
task :ci_strict do
  failed = false

  # Run unit tests
  puts "\n== Running unit tests =="
  Rake::Task["unit_tests"].invoke

  # Run dummy app tests if they exist
  if File.directory?("test/dummy/test/integration")
    puts "\n== Running integration tests =="
    unless system("cd test/dummy && bin/rails test test/integration")
      puts "Warning: Integration tests failed or could not run"
      failed = true
    end
  end

  # Run Rubocop if available
  if system("which rubocop > /dev/null 2>&1")
    puts "\n== Running RuboCop =="
    system("rubocop --format simple")
    failed = true unless $?.success?
  end

  # Fail the build if any step failed
  raise "CI task failed" if failed
end

# Set default task to run everything
task default: :ci
