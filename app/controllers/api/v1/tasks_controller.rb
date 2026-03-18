# frozen_string_literal: true

module Api
  module V1
    class TasksController < Api::BaseController
      before_action :set_task, only: [ :claim, :start, :complete, :fail, :report_cost ]
      before_action :set_agent, only: [ :create, :claim, :start, :complete, :fail, :report_cost ]

      def index
        tasks = if params[:agent_token].present?
          agent = Agent.find_by!(token: params[:agent_token])
          Tasks::PendingForAgent.call(agent: agent)
        else
          Task.where(status: :pending).order(created_at: :asc)
        end
        render json: { tasks: tasks.map { |t| serialize(t) } }
      end

      def create
        goal = Goal.find(params[:goal_id])
        task = Tasks::Create.call(goal: goal, title: params[:title], description: params[:description], agent: @agent)

        if task.persisted?
          render json: { status: "created", task: serialize(task) }
        else
          render json: { error: task.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def claim
        result = Tasks::Claim.call(task: @task, agent: @agent)

        if result[:error]
          render json: { error: result[:error] }, status: :conflict
        else
          system_prompt = Agents::BuildSystemPrompt.call(agent: @agent)
          render json: { status: "claimed", task: serialize(@task.reload), system_prompt: system_prompt }
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

      def report_cost
        result = Tasks::ReportCost.call(task: @task, agent: @agent, cost_cents: params[:cost_cents].to_i)

        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: "recorded", cost_cents: result[:cost_cents] }
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
        { id: task.id, title: task.title, description: task.description, status: task.status, goal_id: task.goal_id }
      end
    end
  end
end
