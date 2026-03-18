# frozen_string_literal: true

module Agents
  module BuildSystemPrompt
    CLI_TOOLS = <<~TOOLS
      Available CLI commands (toko):
        tasks list               — List pending tasks for this agent
        tasks claim <id>         — Claim a pending task
        tasks start <id>         — Mark a claimed task as started
        tasks message <id> <body> — Post a progress message
        tasks result <id> <body>  — Post a result message
        tasks complete <id>      — Mark a started task as completed
        tasks fail <id>          — Mark a task as failed
        tasks relevance <id> <true|false> — Report task relevance
        tasks cost <id> <cents>  — Report task cost in cents
        goals list               — List goals
        goals activate <id>      — Activate a pending goal
        skills ls                — List available skills
        skills load <name>       — Load a skill prompt into context
    TOOLS

    module_function

    def call(agent:)
      parts = []
      parts << org_policy(agent)
      parts << agent_mission(agent)
      parts << CLI_TOOLS
      parts.compact.join("\n\n")
    end

    def org_policy(agent)
      policy = agent.organization&.policy&.body
      return nil unless policy

      "## Organization Policy\n#{policy}"
    end

    def agent_mission(agent)
      mission = agent.mission&.body
      return nil unless mission

      "## Your Mission\n#{mission}"
    end

    private_class_method :org_policy, :agent_mission
  end
end
