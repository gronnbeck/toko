# frozen_string_literal: true

class TimeoutTasksJob < ApplicationJob
  queue_as :default

  def perform
    Tasks::TimeoutExpired.call
  end
end
