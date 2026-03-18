# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Harness
  class ServerClient
    def initialize(config)
      @base_url = config.server_url
      @api_key = config.api_key
    end

    def ping_agent(token, status: "online")
      post("/api/v1/agents/#{token}/ping", { status: })
    end

    def fetch_pending_tasks(agent_token: nil)
      path = "/api/v1/tasks"
      path += "?agent_token=#{agent_token}" if agent_token
      get(path)
    end

    def claim_task(task_id, agent_token:)
      post("/api/v1/tasks/#{task_id}/claim", { agent_token: })
    end

    def start_task(task_id, agent_token:)
      post("/api/v1/tasks/#{task_id}/start", { agent_token: })
    end

    def complete_task(task_id, agent_token:)
      post("/api/v1/tasks/#{task_id}/complete", { agent_token: })
    end

    def fail_task(task_id, error:, agent_token:)
      post("/api/v1/tasks/#{task_id}/fail", { error:, agent_token: })
    end

    def post_message(task_id, body:, agent_token:)
      post("/api/v1/tasks/#{task_id}/messages", { body:, kind: "message", agent_token: })
    end

    def post_result(task_id, body:, agent_token:)
      post("/api/v1/tasks/#{task_id}/messages", { body:, kind: "result", agent_token: })
    end

    def report_relevance(task_id, relevant:, agent_token:)
      post("/api/v1/tasks/#{task_id}/relevance", { relevant:, agent_token: })
    end

    def fetch_goals(organization_id: nil)
      path = "/api/v1/goals"
      path += "?organization_id=#{organization_id}" if organization_id
      get(path)
    end

    def activate_goal(goal_id)
      post("/api/v1/goals/#{goal_id}/activate", {})
    end

    def report_cost(task_id, cost_cents:, agent_token:)
      post("/api/v1/tasks/#{task_id}/report_cost", { cost_cents:, agent_token: })
    end

    def check_budget(agent_token:)
      get("/api/v1/agents/#{agent_token}/budget_check")
    end

    def fetch_skills(agent_token:)
      get("/api/v1/agents/#{agent_token}/skills")
    end

    def load_skill(skill_name, agent_token:)
      get("/api/v1/agents/#{agent_token}/skills/#{skill_name}")
    end

    private

    def get(path)
      uri = URI("#{@base_url}#{path}")
      req = Net::HTTP::Get.new(uri)
      request(uri, req)
    end

    def post(path, body)
      uri = URI("#{@base_url}#{path}")
      req = Net::HTTP::Post.new(uri)
      req.body = body.to_json
      request(uri, req)
    end

    def request(uri, req)
      req["Authorization"] = "Bearer #{@api_key}"
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |h| h.request(req) }
      JSON.parse(res.body, symbolize_names: true)
    rescue JSON::ParserError
      { error: "Invalid JSON response (HTTP #{res&.code})" }
    end
  end
end
