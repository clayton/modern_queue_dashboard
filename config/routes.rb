# frozen_string_literal: true

ModernQueueDashboard::Engine.routes.draw do
  root to: "dashboard#index"

  resources :queues, only: %i[index show]

  # Debug route for troubleshooting
  get "debug", to: "dashboard#debug"
end
