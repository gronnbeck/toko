# frozen_string_literal: true

module Components
  class TaskCard < ApplicationComponent
    STATUS_STYLES = {
      "pending"     => "background:#e5e7eb;color:#374151",
      "in_progress" => "background:#dbeafe;color:#1d4ed8",
      "completed"   => "background:#dcfce7;color:#15803d",
      "failed"      => "background:#fee2e2;color:#b91c1c"
    }

    def initialize(task:)
      @task = task
    end

    def view_template
      div(style: "border:1px solid #e5e7eb;border-radius:8px;padding:16px;display:flex;justify-content:space-between;align-items:center") do
        span(style: "font-weight:500") { @task.title }
        status_pill
      end
    end

    private

    def status_pill
      style = STATUS_STYLES.fetch(@task.status, STATUS_STYLES["pending"])
      span(style: "#{style};padding:2px 10px;border-radius:999px;font-size:12px;font-weight:600") do
        @task.status.tr("_", " ")
      end
    end
  end
end
