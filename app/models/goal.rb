# frozen_string_literal: true

class Goal < ApplicationRecord
  enum :status, { pending: 0, active: 1, review: 2, completed: 3 }

  belongs_to :organization

  validates :title, presence: true
end
