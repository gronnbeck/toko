# frozen_string_literal: true

require "test_helper"

module Goals
  class UpdateTest < ActiveSupport::TestCase
    setup do
      org = Organization.create!(name: "Acme")
      @goal = Goal.create!(title: "Ship v1", organization: org)
    end

    test "updates goal attributes" do
      result = Goals::Update.call(goal: @goal, params: { title: "Ship v2", description: "Updated" })
      assert result
      assert_equal "Ship v2", @goal.reload.title
      assert_equal "Updated", @goal.description
    end

    test "returns false with invalid params" do
      result = Goals::Update.call(goal: @goal, params: { title: "", description: "Nope" })
      assert_not result
    end
  end
end
