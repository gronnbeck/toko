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

    def fetch_pending_tasks
      get("/api/v1/tasks?status=pending")
    end

    def claim_task(task_id)
      post("/api/v1/tasks/#{task_id}/claim", {})
    end

    def complete_task(task_id, output:)
      post("/api/v1/tasks/#{task_id}/complete", { output: })
    end

    def fail_task(task_id, error:)
      post("/api/v1/tasks/#{task_id}/fail", { error: })
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
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |h| h.request(req) }
      JSON.parse(res.body, symbolize_names: true)
    end
  end
end
