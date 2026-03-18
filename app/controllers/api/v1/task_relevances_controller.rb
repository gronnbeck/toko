# frozen_string_literal: true

module Api
  module V1
    class TaskRelevancesController < Api::BaseController
      def create
        task = Task.find(params[:task_id])
        agent = Agent.find_by!(token: params[:agent_token])

        result = Tasks::CheckRelevance.call(
          task: task, agent: agent, relevant: ActiveModel::Type::Boolean.new.cast(params[:relevant])
        )

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "recorded" }, status: :created
        end
      end
    end
  end
end
