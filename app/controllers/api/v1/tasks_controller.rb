# frozen_string_literal: true

module Api
  module V1
    class TasksController < Api::BaseController
      # GET /api/v1/tasks?status=pending
      def index
        # TODO: implement
        render json: { tasks: [] }
      end

      # POST /api/v1/tasks/:id/claim
      def claim
        # TODO: implement
        render json: { status: "claimed" }
      end

      # POST /api/v1/tasks/:id/complete
      def complete
        # TODO: implement
        render json: { status: "completed" }
      end

      # POST /api/v1/tasks/:id/fail
      def fail
        # TODO: implement
        render json: { status: "failed" }
      end
    end
  end
end
