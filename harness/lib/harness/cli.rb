# frozen_string_literal: true

module Harness
  class CLI
    USAGE = <<~USAGE
      Usage: toko <command> [args]

      Commands:
        tasks list               List pending tasks
        tasks claim <id>         Claim a task (exits 0 on success, 1 if already claimed)
        tasks complete <id>      Mark a task as complete
        tasks fail <id>          Mark a task as failed
    USAGE

    def initialize(client:, token:)
      @client = client
      @token = token
    end

    def run(argv)
      resource, command, *args = argv

      case [ resource, command ]
      in [ "tasks", "list" ]     then tasks_list
      in [ "tasks", "claim" ]    then tasks_claim(args.first)
      in [ "tasks", "complete" ] then tasks_complete(args.first)
      in [ "tasks", "fail" ]     then tasks_fail(args.first)
      else
        puts USAGE
        exit 1
      end
    end

    private

    attr_reader :client, :token

    def tasks_list
      result = client.fetch_pending_tasks
      tasks = result.fetch(:tasks, [])
      if tasks.empty?
        puts "No pending tasks."
      else
        tasks.each { |t| puts "#{t[:id]}\t#{t[:title]}\t#{t[:status]}" }
      end
    end

    def tasks_claim(id)
      abort "task id required" unless id
      result = client.claim_task(id)
      if result[:status] == "claimed"
        puts "Claimed task #{id}."
      else
        warn "Could not claim task #{id}: #{result[:error]}"
        exit 1
      end
    end

    def tasks_complete(id)
      abort "task id required" unless id
      client.complete_task(id, output: nil)
      puts "Task #{id} marked complete."
    end

    def tasks_fail(id)
      abort "task id required" unless id
      client.fail_task(id, error: "failed via CLI")
      puts "Task #{id} marked failed."
    end
  end
end
