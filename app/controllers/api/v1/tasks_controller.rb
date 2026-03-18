# frozen_string_literal: true

module Api
  module V1
    class TasksController < Api::BaseController
      before_action :set_task, only: [ :claim, :start, :complete, :fail ]
      before_action :set_agent, only: [ :claim, :start, :complete, :fail ]

      def index
        tasks = if params[:agent_token].present?
          agent = Agent.find_by!(token: params[:agent_token])
          Tasks::PendingForAgent.call(agent: agent)
        else
          Task.where(status: :pending).order(created_at: :asc)
        end
        render json: { tasks: tasks.map { |t| serialize(t) } }
      end

      def claim
        result = Tasks::Claim.call(task: @task, agent: @agent)

        if result[:error]
          render json: { error: result[:error] }, status: :conflict
        else
          render json: { status: "claimed", task: serialize(@task.reload) }
        end
      end

      def start
        result = Tasks::Start.call(task: @task, agent: @agent)

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "started" }
        end
      end

      def complete
        result = Tasks::Complete.call(task: @task, agent: @agent)

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "completed" }
        end
      end

      def fail
        result = Tasks::Fail.call(task: @task, agent: @agent)

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "failed" }
        end
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def set_agent
        @agent = Agent.find_by!(token: params[:agent_token])
      end

      def serialize(task)
        { id: task.id, title: task.title, status: task.status }
      end
    end
  end
end
