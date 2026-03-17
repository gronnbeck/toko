# frozen_string_literal: true

class Agent < ApplicationRecord
  enum :status, { idle: 0, busy: 1, offline: 2 }

  validates :name, presence: true
end
