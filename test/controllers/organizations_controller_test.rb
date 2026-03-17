# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @org = Organization.create!(name: "Acme")
  end

  test "GET index renders successfully" do
    get organizations_path
    assert_response :success
  end

  test "GET show renders successfully" do
    get organization_path(@org)
    assert_response :success
  end

  test "PATCH update changes name" do
    patch organization_path(@org), params: { organization: { name: "Acme Corp" } }
    assert_redirected_to organization_path(@org)
    assert_equal "Acme Corp", @org.reload.name
  end

  test "PATCH update with invalid params re-renders show" do
    patch organization_path(@org), params: { organization: { name: "" } }
    assert_response :unprocessable_entity
  end
end
