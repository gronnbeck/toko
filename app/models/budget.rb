# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :organization

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
