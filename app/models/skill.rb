# frozen_string_literal: true

class Skill < ApplicationRecord
  has_many :agent_skills, dependent: :destroy
  has_many :agents, through: :agent_skills
  has_one :prompt, -> { where(kind: :skill) }, class_name: "Prompt", as: :promptable, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
