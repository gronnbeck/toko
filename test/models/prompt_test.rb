# frozen_string_literal: true

require "test_helper"

class PromptTest < ActiveSupport::TestCase
  setup do
    @agent = Agent.create!(name: "Agent 1")
  end

  test "valid with body, kind, and promptable" do
    prompt = Prompt.new(body: "You are a helpful agent.", kind: :mission, promptable: @agent)
    assert prompt.valid?
  end

  test "invalid without body" do
    prompt = Prompt.new(kind: :mission, promptable: @agent)
    assert_not prompt.valid?
  end

  test "defaults to mission kind" do
    prompt = Prompt.create!(body: "You are helpful.", promptable: @agent)
    assert prompt.mission?
  end

  test "invalid without promptable" do
    prompt = Prompt.new(body: "You are helpful.", kind: :mission)
    assert_not prompt.valid?
  end
end
