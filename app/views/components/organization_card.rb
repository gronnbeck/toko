# frozen_string_literal: true

module Components
  class OrganizationCard < ApplicationComponent
    def initialize(organization:)
      @organization = organization
    end

    def view_template
      a(href: "/organizations/#{@organization.id}", class: "agent-card") do
        span(class: "agent-card__name") { @organization.name }
        span(class: "org-card__agents") { "#{@organization.agents.count} agents" }
      end
    end
  end
end
