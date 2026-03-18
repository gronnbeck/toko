# frozen_string_literal: true

require "test_helper"

module Goals
  class CreateTest < ActiveSupport::TestCase
    setup do
      @org = Organization.create!(name: "Acme")
    end

    test "creates a goal with valid params" do
      goal = Goals::Create.call(organization: @org, params: { title: "Ship v1", description: "Launch it" })
      assert goal.persisted?
      assert_equal "Ship v1", goal.title
      assert_equal @org, goal.organization
    end

    test "returns invalid goal without title" do
      goal = Goals::Create.call(organization: @org, params: { title: "", description: "Nope" })
      assert_not goal.persisted?
    end
  end
end
