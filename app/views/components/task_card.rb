# frozen_string_literal: true

module Components
  class TaskCard < ApplicationComponent
    def initialize(task:)
      @task = task
    end

    def view_template
      div(class: "task-card") do
        span(class: "task-card__title") { @task.title }
        span(class: "status-pill status-pill--#{@task.status}") { @task.status.tr("_", " ") }
      end
    end
  end
end
