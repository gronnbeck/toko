# frozen_string_literal: true

class Task < ApplicationRecord
  enum :status, { pending: 0, claimed: 1, started: 2, completed: 3, failed: 4, timed_out: 5 }

  belongs_to :claimed_by, class_name: "Agent", optional: true
  has_many :task_messages, dependent: :destroy

  validates :title, presence: true

  def result_message
    task_messages.find_by(kind: :result)
  end
end
