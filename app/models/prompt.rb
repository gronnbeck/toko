# frozen_string_literal: true

class Prompt < ApplicationRecord
  enum :kind, { mission: 0, policy: 1 }

  belongs_to :promptable, polymorphic: true

  validates :body, presence: true
end
