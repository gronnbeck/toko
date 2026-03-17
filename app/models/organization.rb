# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :agents, dependent: :destroy
  has_one :mission, -> { where(kind: :mission) }, class_name: "Prompt", as: :promptable, dependent: :destroy
  has_one :policy, -> { where(kind: :policy) }, class_name: "Prompt", as: :promptable, dependent: :destroy

  validates :name, presence: true
end
