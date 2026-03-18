# frozen_string_literal: true

class BudgetsController < ApplicationController
  def update
    org = Organization.find(params[:organization_id])

    if Budgets::Update.call(organization: org, amount_cents: params[:budget][:amount_cents])
      redirect_to organization_path(org)
    else
      render ::Views::Organizations::Show.new(organization: org), status: :unprocessable_entity
    end
  end
end
