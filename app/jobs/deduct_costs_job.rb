# frozen_string_literal: true

class DeductCostsJob < ApplicationJob
  queue_as :default

  def perform
    Budgets::DeductCosts.call
  end
end
