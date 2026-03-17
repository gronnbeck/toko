# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :update ]

  def index
    organizations = Organization.order(created_at: :desc)
    render ::Views::Organizations::Index.new(organizations:)
  end

  def show
    render ::Views::Organizations::Show.new(organization: @organization)
  end

  def update
    if Organizations::Update.call(organization: @organization, params: organization_params)
      redirect_to organization_path(@organization)
    else
      render ::Views::Organizations::Show.new(organization: @organization), status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :mission_body, :policy_body)
  end
end
