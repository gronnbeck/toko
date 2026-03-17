# frozen_string_literal: true

class AgentsController < ApplicationController
  def index
    agents = Agent.order(created_at: :desc)
    render ::Views::Agents::Index.new(agents:)
  end
end
