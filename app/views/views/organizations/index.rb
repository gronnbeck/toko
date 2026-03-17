# frozen_string_literal: true

module Views
  module Organizations
    class Index < ApplicationView
      def initialize(organizations:)
        @organizations = organizations
      end

      def view_template
        div(class: "home") do
          h1(class: "home__title") { "Organizations" }
          if @organizations.any?
            div(class: "task-grid") do
              @organizations.each { |org| render ::Components::OrganizationCard.new(organization: org) }
            end
          else
            p(class: "home__empty") { "No organizations yet." }
          end
        end
      end
    end
  end
end
