# frozen_string_literal: true

module Views
  module Home
    class Index < ApplicationView
      def initialize(tasks:)
        @tasks = tasks
      end

      def view_template
        div(style: "max-width:640px;margin:40px auto;padding:0 16px;font-family:sans-serif") do
          h1(style: "margin-bottom:24px") { "Welcome to Toko" }
          if @tasks.any?
            div(style: "display:flex;flex-direction:column;gap:12px") do
              @tasks.each { |task| render ::Components::TaskCard.new(task:) }
            end
          else
            p(style: "color:#6b7280") { "No tasks yet." }
          end
        end
      end
    end
  end
end
