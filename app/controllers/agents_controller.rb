# frozen_string_literal: true

class AgentsController < ApplicationController
  before_action :set_agent, only: [ :show, :update ]

  def index
    agents = Agent.order(created_at: :desc)
    render ::Views::Agents::Index.new(agents:)
  end

  def show
    render ::Views::Agents::Show.new(agent: @agent)
  end

  def update
    if Agents::Update.call(agent: @agent, params: agent_params)
      redirect_to agent_path(@agent)
    else
      render ::Views::Agents::Show.new(agent: @agent), status: :unprocessable_entity
    end
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:name, :description, :mission_body)
  end
end
