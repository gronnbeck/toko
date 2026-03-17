# frozen_string_literal: true

module Organizations
  module Update
    module_function

    def call(organization:, params:)
      return false unless organization.update(name: params[:name])

      upsert_prompt(organization, :mission, params[:mission_body])
      upsert_prompt(organization, :policy, params[:policy_body])
      true
    end

    def upsert_prompt(organization, kind, body)
      return if body.nil?

      existing = Prompt.find_by(promptable: organization, kind:)

      if body.blank?
        existing&.destroy
      elsif existing
        existing.update!(body:)
      else
        Prompt.create!(body:, kind:, promptable: organization)
      end
    end

    private_class_method :upsert_prompt
  end
end
