# frozen_string_literal: true

module Goals
  module Create
    module_function

    def call(organization:, params:)
      Goal.create(
        organization:,
        title: params[:title],
        description: params[:description]
      )
    end
  end
end
