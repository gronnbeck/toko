# frozen_string_literal: true

module Tasks
  module TimeoutExpired
    module_function

    def call
      Task.where(status: [ :claimed, :started ])
          .where("timeout_at <= ?", Time.current)
          .find_each { |task| task.update!(status: :timed_out) }
    end
  end
end
