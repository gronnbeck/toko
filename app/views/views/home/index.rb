# frozen_string_literal: true

module Views
  module Home
    class Index < ApplicationView
      def view_template
        h1 { "Welcome to Toko" }
      end
    end
  end
end
