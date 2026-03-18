class AgentSkillsController < ApplicationController
  before_action :set_agent

  def create
    if params[:skill_id].present?
      assign_existing_skill
    else
      create_and_assign_skill
    end
    redirect_to agent_path(@agent)
  end

  def destroy
    @agent.agent_skills.find(params[:id]).destroy
    redirect_to agent_path(@agent)
  end

  private

  def set_agent
    @agent = Agent.find(params[:agent_id])
  end

  def assign_existing_skill
    skill = Skill.find(params[:skill_id])
    AgentSkill.find_or_create_by!(agent: @agent, skill:)
  end

  def create_and_assign_skill
    skill = Skill.create!(name: skill_params[:name], keywords: skill_params[:keywords], description: skill_params[:description])
    upsert_prompt(skill, skill_params[:prompt_body])
    AgentSkill.create!(agent: @agent, skill:)
  end

  def upsert_prompt(skill, body)
    return if body.blank?
    Prompt.create!(body:, kind: :skill, promptable: skill)
  end

  def skill_params
    params.require(:skill).permit(:name, :keywords, :description, :prompt_body)
  end
end
