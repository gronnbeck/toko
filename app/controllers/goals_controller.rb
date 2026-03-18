# frozen_string_literal: true

class GoalsController < ApplicationController
  before_action :set_goal, only: [ :show, :edit, :update, :destroy, :transition ]

  def index
    goals = Goal.order(created_at: :desc)
    render ::Views::Goals::Index.new(goals:)
  end

  def new
    goal = Goal.new
    render ::Views::Goals::New.new(goal:, organizations: Organization.all)
  end

  def create
    org = Organization.find(goal_params[:organization_id])
    goal = Goals::Create.call(organization: org, params: goal_params)

    if goal.persisted?
      redirect_to goal_path(goal)
    else
      render ::Views::Goals::New.new(goal:, organizations: Organization.all), status: :unprocessable_entity
    end
  end

  def show
    render ::Views::Goals::Show.new(goal: @goal)
  end

  def edit
    render ::Views::Goals::Edit.new(goal: @goal)
  end

  def update
    if Goals::Update.call(goal: @goal, params: goal_params)
      redirect_to goal_path(@goal)
    else
      render ::Views::Goals::Edit.new(goal: @goal), status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    redirect_to goals_path
  end

  def transition
    if params[:status] == "active"
      Goals::Activate.call(goal: @goal)
    else
      @goal.update!(status: params[:status])
    end
    redirect_to goal_path(@goal)
  end

  private

  def set_goal
    @goal = Goal.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :organization_id)
  end
end
