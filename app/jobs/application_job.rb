class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  rescue_from(Exception) do |exception|
    context = {
      error_class: self.class.name,
      args: self.arguments,
      scheduled_at: self.scheduled_at,
      job_id: self.job_id
    }
    Honeybadger.notify(exception, context:)
    raise exception
  end
end
