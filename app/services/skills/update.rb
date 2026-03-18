module Skills
  module Update
    module_function

    def call(skill:, params:)
      return false unless skill.update(name: params[:name], keywords: params[:keywords], description: params[:description])
      upsert_prompt(skill, params[:prompt_body])
      true
    end

    def upsert_prompt(skill, body)
      return if body.nil?
      existing = Prompt.find_by(promptable: skill, kind: :skill)
      if body.blank?
        existing&.destroy
      elsif existing
        existing.update!(body:)
      else
        Prompt.create!(body:, kind: :skill, promptable: skill)
      end
    end

    private_class_method :upsert_prompt
  end
end
