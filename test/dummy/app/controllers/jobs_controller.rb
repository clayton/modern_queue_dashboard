class JobsController < ApplicationController
  def create
    # Enqueue a test job
    TestJob.perform_later("test argument", Time.current.to_s)

    redirect_to root_path, notice: "Test job enqueued!"
  end
end
