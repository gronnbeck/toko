# frozen_string_literal: true

module Views
  module Home
    class Index < ApplicationView
      def initialize(tasks:)
        @tasks = tasks
      end

      def view_template
        div(class: "home") do
          h1(class: "home__title") { "Welcome to Toko" }
          if @tasks.any?
            div(class: "task-grid") do
              @tasks.each { |task| render ::Components::TaskCard.new(task:) }
            end
          else
            p(class: "home__empty") { "No tasks yet." }
          end
        end
      end
    end
  end
end
