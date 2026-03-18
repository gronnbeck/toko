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
        result = Goals::Activate.call(goal: goal)

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "active", goal: serialize(goal) }
        end
      end

      private

      def serialize(goal)
        { id: goal.id, title: goal.title, description: goal.description, status: goal.status }
      end
    end
  end
end
