# frozen_string_literal: true

module Api
  module V1
    class TasksController < Api::BaseController
      before_action :set_task, only: [ :claim, :complete, :fail ]
      before_action :set_agent, only: [ :claim, :complete, :fail ]

      def index
        tasks = Task.where(status: :pending).order(created_at: :asc)
        render json: { tasks: tasks.map { |t| serialize(t) } }
      end

      def claim
        if @task.pending?
          @task.update!(status: :claimed, claimed_by: @agent)
          render json: { status: "claimed", task: serialize(@task) }
        else
          render json: { error: "Task already claimed" }, status: :conflict
        end
      end

      def complete
        @task.update!(status: :completed)
        render json: { status: "completed" }
      end

      def fail
        @task.update!(status: :failed)
        render json: { status: "failed" }
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def set_agent
        token = params[:agent_token]
        @agent = Agent.find_by!(token:)
      end

      def serialize(task)
        { id: task.id, title: task.title, status: task.status }
      end
    end
  end
end
