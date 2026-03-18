class SkillsController < ApplicationController
  before_action :set_skill

  def show
    render ::Views::Skills::Show.new(skill: @skill)
  end

  def update
    if Skills::Update.call(skill: @skill, params: skill_params)
      redirect_to skill_path(@skill)
    else
      render ::Views::Skills::Show.new(skill: @skill), status: :unprocessable_entity
    end
  end

  def destroy
    @skill.destroy
    redirect_to params[:agent_id] ? agent_path(params[:agent_id]) : agents_path
  end

  private

  def set_skill
    @skill = Skill.find(params[:id])
  end

  def skill_params
    params.require(:skill).permit(:name, :keywords, :description, :prompt_body)
  end
end
