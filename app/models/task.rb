# frozen_string_literal: true

class Task < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2, failed: 3 }

  belongs_to :claimed_by, class_name: "Agent", optional: true

  validates :title, presence: true
end
