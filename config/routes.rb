# frozen_string_literal: true

ModernQueueDashboard::Engine.routes.draw do
  root to: "dashboard#index"

  resources :queues, only: %i[index show] do
    member do
      post "retry_job/:job_id", to: "queues#retry_job", as: "retry_job"
      delete "discard_job/:job_id", to: "queues#discard_job", as: "discard_job"
      get "status/:status", to: "queues#show", as: "status"
    end
  end

  resources :jobs, only: [ :show ] do
    member do
      post "retry", to: "jobs#retry"
      delete "discard", to: "jobs#discard"
    end
  end

  # Debug route for troubleshooting
  get "debug", to: "dashboard#debug"
end
