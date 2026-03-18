# frozen_string_literal: true

class TaskMessage < ApplicationRecord
  enum :kind, { message: 0, result: 1 }

  belongs_to :task
  belongs_to :agent

  validates :body, presence: true
end
