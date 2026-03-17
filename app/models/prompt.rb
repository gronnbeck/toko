# frozen_string_literal: true

class Prompt < ApplicationRecord
  belongs_to :agent

  validates :body, presence: true
end
