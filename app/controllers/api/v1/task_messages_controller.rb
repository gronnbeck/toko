# frozen_string_literal: true

module Api
  module V1
    class TaskMessagesController < Api::BaseController
      before_action :set_task
      before_action :set_agent, only: :create

      def index
        messages = @task.task_messages.order(created_at: :asc)
        render json: { messages: messages.map { |m| serialize(m) } }
      end

      def create
        result = Tasks::PostMessage.call(
          task: @task, agent: @agent,
          body: params[:body], kind: params.fetch(:kind, :message)
        )

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "created", message: serialize(result[:message]) }, status: :created
        end
      end

      private

      def set_task
        @task = Task.find(params[:task_id])
      end

      def set_agent
        @agent = Agent.find_by!(token: params[:agent_token])
      end

      def serialize(msg)
        { id: msg.id, body: msg.body, kind: msg.kind, created_at: msg.created_at }
      end
    end
  end
end
