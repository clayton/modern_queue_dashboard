## [Unreleased]

## [0.5.3] - 2025-01-07

- Updated pagy dependency specification to ">= 7.0.0", "< 10.0" for better version range control

## [0.5.2] - 2025-01-07

- Fixed pagy dependency specification to use semantic versioning best practices
- Updated pagy dependency from ">= 7.0.0" to "~> 7.0", ">= 7.0.0" to eliminate gemspec warnings

## [0.5.1] - 2025-01-07

- Fixed job details view to properly display error information for failed jobs
- Improved error message display and exception handling in job views
- Enhanced job status display and error information accessibility

## [0.5.0] - 2025-05-20

- Added job retry and discard functionality
- Implemented status filtering with pagination
- Updated job summary display with enhanced information
- Added pagination support using Pagy
- Updated queue and job models to accommodate new features
- Improved error handling throughout the application

## [0.4.1] - 2025-05-19

- Fixed issue with jobs that have no arguments showing "Error parsing arguments"
- Improved argument handling and display in job tables

## [0.4.0] - 2025-05-19

- Changed Tailwind's Sky color to Blue color for better contrast
- Added jobs table to queue view showing up to 50 most recent jobs with their status
- Added recent jobs table to main dashboard showing 10 most recent jobs across all queues
- Added color-coded status indicators for jobs
- Display detailed error information for failed jobs

## [0.3.2] - 2025-05-19

- Fixed issue with load order

## [0.3.1] - 2025-05-19

- Fixed compatibility with Solid Queue's database schema
- Updated queries to properly read from Solid Queue's execution tables:
  - Ready jobs from `solid_queue_ready_executions`
  - Scheduled jobs from `solid_queue_scheduled_executions`
  - Running jobs from `solid_queue_claimed_executions`
  - Failed jobs from `solid_queue_failed_executions`
- Added error handling for cases where tables might not be available
- Updated README to clarify that this dashboard is exclusively for Solid Queue

## [0.3.0] - 2025-05-19

- Updated tailwindcss-rails dependency to ~> 4.0
- Updated turbo-rails dependency to ~> 2.0
- Improved compatibility with Rails 8.0.2

## [0.2.2] - 2025-05-18

- Fixed CI workflow to run RuboCop and fail the build if there are issues
- Added a CHANGELOG.md file
- Added a Gemfile.lock file

## [0.2.1] - 2023-07-30

- Updated UI color scheme from indigo to sky blue
- Fixed Tailwind CSS configuration and build process

## [0.2.0] - 2023-07-28

- Added CI workflow with GitHub Actions
- Integrated RuboCop with Rails Omakase style
- Added proper test setup including unit and integration tests
- Improved engine compatibility with Rails 8 asset systems
- Added developer documentation and test helpers

## [0.1.0] - 2023-07-25

- Initial release
