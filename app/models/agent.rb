# frozen_string_literal: true

class Agent < ApplicationRecord
  enum :status, { idle: 0, busy: 1, offline: 2 }

  has_one :mission, class_name: "Prompt", dependent: :destroy

  validates :name, presence: true
end
