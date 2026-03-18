# frozen_string_literal: true

module Components
  class Nav < ApplicationComponent
    NAV_ITEMS = [
      { label: "Tasks",         path: "/" },
      { label: "Agents",        path: "/agents" },
      { label: "Goals",         path: "/goals" },
      { label: "Organizations", path: "/organizations" }
    ].freeze

    def initialize(current_path:)
      @current_path = current_path
    end

    def view_template
      nav(class: "nav") do
        a(href: "/", class: "nav__brand") { "Toko" }
        NAV_ITEMS.each do |item|
          a(href: item[:path], class: nav_item_class(item[:path])) { item[:label] }
        end
      end
    end

    private

    def nav_item_class(path)
      active = @current_path == path
      "nav__item#{" nav__item--active" if active}"
    end
  end
end
