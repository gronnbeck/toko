require "test_helper"

class Skills::UpdateTest < ActiveSupport::TestCase
  setup do
    @skill = Skill.create!(name: "update-test-#{SecureRandom.hex(4)}", keywords: "old", description: "Old desc")
  end

  test "updates skill attributes" do
    result = Skills::Update.call(skill: @skill, params: { name: @skill.name, keywords: "new", description: "New desc" })
    assert result
    assert_equal "new", @skill.reload.keywords
    assert_equal "New desc", @skill.reload.description
  end

  test "creates prompt when none exists" do
    Skills::Update.call(skill: @skill, params: { name: @skill.name, prompt_body: "Do stuff" })
    assert_equal "Do stuff", @skill.reload.prompt.body
  end

  test "updates existing prompt" do
    Prompt.create!(body: "Old prompt", kind: :skill, promptable: @skill)
    Skills::Update.call(skill: @skill, params: { name: @skill.name, prompt_body: "New prompt" })
    assert_equal "New prompt", @skill.reload.prompt.body
  end

  test "removes prompt when body is blank" do
    Prompt.create!(body: "Will remove", kind: :skill, promptable: @skill)
    Skills::Update.call(skill: @skill, params: { name: @skill.name, prompt_body: "" })
    assert_nil @skill.reload.prompt
  end

  test "returns false when name is blank" do
    result = Skills::Update.call(skill: @skill, params: { name: "" })
    refute result
  end
end
