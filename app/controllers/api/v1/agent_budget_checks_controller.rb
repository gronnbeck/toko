# frozen_string_literal: true

module Api
  module V1
    class AgentBudgetChecksController < Api::BaseController
      def show
        agent = Agent.find_by!(token: params[:agent_token])
        result = Budgets::CheckAgentDaily.call(agent: agent)
        render json: result
      end
    end
  end
end
