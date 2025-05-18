# Modern Queue Dashboard – Implementation Plan

## 1. Purpose
Create a mountable Rails engine (`modern_queue_dashboard`) that provides a Hotwire-powered, Tailwind-styled dashboard for monitoring Solid Queue job activity. The gem should be install-and-mount with zero configuration, MIT-licensed, Rails 8+ compatible.

---

## 2. Feature Scope
1. **High-level metrics**
   * Total jobs per state: pending, scheduled, running, completed, discarded, failed.
   * Per-queue counts and latency (oldest `run_at` vs now).
2. **Queue list** – table of all queues with counts & oldest job age.
3. **Job list** – paginated view for a selected queue or global list.
4. **Job detail** – arguments, id, state transitions, timestamps, error details for failed jobs.
5. **Semi-real-time updates** – Turbo Stream polling every *n* seconds (configurable).
6. **No job actions** (read-only).
7. **Authentication left to host app** – README shows Devise/warden examples.

---

## 3. Data Sources & Queries
Solid Queue tables (≥ v1.1):
* `solid_queue_jobs`
* `solid_queue_executions`
* `solid_queue_queues`
* `solid_queue_failed_jobs`
* `solid_queue_scheduled_jobs`
* `solid_queue_workers` (for running jobs)

Create PORO query objects under `app/models/modern_queue_dashboard/` to encapsulate:
* `Metrics.summary` – returns counts/latency.
* `Queue.with_stats` – returns per-queue stats.
* `JobFinder` – fetches jobs by queue / state with eager-loaded execution & failure.
* `JobPresenter` – formats metadata for the UI.

---

## 4. Gem/Engine Skeleton
```
modern_queue_dashboard/
├── app/
│   ├── controllers/modern_queue_dashboard/
│   ├── views/modern_queue_dashboard/
│   ├── models/modern_queue_dashboard/
│   ├── components/modern_queue_dashboard/ (ViewComponent or Phlex?)
│   ├── assets/
│   │   ├── stylesheets/modern_queue_dashboard.css
│   │   └── javascript/modern_queue_dashboard.js
│   └── helpers/modern_queue_dashboard/
├── config/
│   ├── routes.rb (Engine)
│   └── initializers/assets.rb (precompile dashboard assets)
├── lib/
│   ├── modern_queue_dashboard.rb (engine loader)
│   ├── modern_queue_dashboard/engine.rb
│   └── modern_queue_dashboard/version.rb
├── test/
│   ├── dummy/ (rails new --minimal --edge)
│   └── ... unit tests (Minitest)
├── Rakefile
└── modern_queue_dashboard.gemspec
```

---

## 5. Dependencies
* `rails ">= 8.0.0"`
* `turbo-rails`, `stimulus-rails` (already bundled with Rails 8)
* `tailwindcss-rails`
* `view_component` (optional – decide in §8)
* `solid_queue` (runtime, same version constraint as host)
* Development: `standard`/`rubocop`, `minitest-reporters`, `pry`.

---

## 6. Routes
Within the engine (`config/routes.rb`):
```ruby
ModernQueueDashboard::Engine.routes.draw do
  root to: "dashboard#index"
  resources :queues, only: [:index, :show] do
    resources :jobs, only: [:index]
  end
  resources :jobs, only: [:show]
  get "metrics", to: "metrics#show"  # JSON for Turbo polling
end
```

---

## 7. Controllers
* `DashboardController#index` – loads Metrics & queues.
* `QueuesController#index` – list with stats.
* `QueuesController#show` – queue overview & first page of jobs.
* `JobsController#index` – filtered list by queue/state.
* `JobsController#show` – job detail.
* `MetricsController#show` – returns partial/stream fragment for live refresh.

All inherit from `ModernQueueDashboard::ApplicationController`, which defines layout & before_actions.

---

## 8. Views & Components
* Use **Turbo Frames** to update sections without full-page reload.
* Tailwind classes for styling; minimal custom CSS.
* Consider **ViewComponent** (optional) for reusable pieces (metric card, table row).

Pages:
1. **Dashboard** – metric cards + table of top 10 queues.
2. **Queue show** – header (stats) + jobs table.
3. **Job show** – read-only details with collapsible JSON args & error.

---

## 9. Hotwire Behaviour
* Stimulus controller `refresh_controller.js` fetches `/metrics` every N seconds (default 5) and updates via Turbo.
* Jobs/queue pages optionally auto-refresh lists.
* Configurable via `ModernQueueDashboard.configuration.refresh_interval`.

---

## 10. Styling / Assets
* `tailwindcss-rails` build task generates `modern_queue_dashboard.css`.
* Color palette close to Active Storage Dashboard (gray/indigo).
* Provide a helper to override Tailwind config via initializer if host app precompiles their own CSS.
* Ship minified CSS/JS in the gem (`app/assets/builds`).

---

## 11. Configuration API
```ruby
# config/initializers/modern_queue_dashboard.rb
ModernQueueDashboard.configure do |config|
  config.refresh_interval = 5
  config.time_zone = "UTC"
end
```

Defaults live in `ModernQueueDashboard::Configuration`.

---

## 12. Authentication Guidance (README)
```ruby
# config/routes.rb in host app
authenticate :user, -> { _1.admin? } do
  mount ModernQueueDashboard::Engine, at: "/modern-queue-dashboard"
end
```
Or rack basic auth example.

---

## 13. Testing Strategy (Minitest)
* **Models/Queries**: unit tests.
* **Controllers**: request specs.
* **Components**: view/component tests.
* Dummy app under `test/dummy` for engine isolation.
* No system tests; rely on controller tests + minimal Turbo response assertions.

---

## 14. CI
* GitHub Actions: run `bundle exec rake test`, Rubocop, `rails test:dummy` against sqlite3.
* Matrix for latest stable Ruby & JRuby.

---

## 15. Release & Versioning
* Semantic versioning starting at `0.1.0`.
* Publish to RubyGems when dashboard feature-complete.

---

## 16. Future Enhancements (out-of-scope for 0.1.0)
* Job actions (retry, discard, delete).
* Prometheus/JSON metrics.
* Live WebSocket updates instead of polling.
* Scheduler/Recurring task visualizer.
* Dark mode theme.
* System tests (Turbo-flavored).

---

## 17. Implementation Roadmap
1. **Bootstrap gem** – `bundle gem modern_queue_dashboard --mit --coc --test=minitest`.
2. **Create engine, routes, layout**.
3. **Add Tailwind & Turbo assets**.
4. **Implement Metrics query object**.
5. **Build DashboardController & dashboard view**.
6. **Queue stats & pages**.
7. **Job finder & details page**.
8. **Stimulus polling**.
9. **Configuration DSL**.
10. **Dummy app + tests**.
11. **README & screenshots**.
12. **Precompile assets & ship builds**.
13. **Set up CI**.
14. **Tag `v0.1.0` and release.**

---