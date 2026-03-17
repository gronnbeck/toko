# frozen_string_literal: true

class Agent < ApplicationRecord
  enum :status, { idle: 0, busy: 1, offline: 2 }

  belongs_to :organization, optional: true
  has_one :mission, -> { where(kind: :mission) }, class_name: "Prompt", as: :promptable, dependent: :destroy

  validates :name, presence: true
end
