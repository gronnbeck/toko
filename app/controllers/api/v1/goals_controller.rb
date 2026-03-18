# frozen_string_literal: true

module Api
  module V1
    class GoalsController < Api::BaseController
      def index
        goals = if params[:organization_id].present?
          Goal.where(organization_id: params[:organization_id])
        else
          Goal.all
        end
        render json: { goals: goals.map { |g| serialize(g) } }
      end

      def activate
        goal = Goal.find(params[:id])

        if goal.pending?
          goal.update!(status: :active)
          render json: { status: "active", goal: serialize(goal) }
        else
          render json: { error: "Goal is not pending" }, status: :unprocessable_entity
        end
      end

      private

      def serialize(goal)
        { id: goal.id, title: goal.title, description: goal.description, status: goal.status }
      end
    end
  end
end
