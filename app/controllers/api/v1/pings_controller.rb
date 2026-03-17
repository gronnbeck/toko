# frozen_string_literal: true

module Api
  module V1
    class PingsController < ApplicationController
      def create
        agent = Agent.find_by(token: params[:agent_token])
        return render json: { error: "Agent not found" }, status: :not_found unless agent

        status = params[:status].presence_in(Agent.statuses.keys) || "online"
        agent.ping!(status: status.to_sym)

        render json: { ok: true, last_seen_at: agent.last_seen_at }
      end
    end
  end
end
