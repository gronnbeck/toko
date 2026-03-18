# frozen_string_literal: true

module Goals
  module Update
    module_function

    def call(goal:, params:)
      goal.update(
        title: params[:title],
        description: params[:description]
      )
    end
  end
end
