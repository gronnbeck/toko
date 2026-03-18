# frozen_string_literal: true

module Harness
  class CLI
    USAGE = <<~USAGE
      Usage: toko <command> [args]

      Commands:
        tasks list                         List pending tasks
        tasks create <goal_id> <title>     Create a task for a goal
        tasks claim <id>                   Claim a task
        tasks start <id>                   Mark a claimed task as started
        tasks complete <id>                Mark a started task as completed
        tasks fail <id>                    Mark a task as failed
        tasks message <id> <body>          Post a progress message
        tasks result <id> <body>           Post a result message
        tasks relevance <id> <true|false>  Report task relevance
        tasks cost <id> <cents>            Report task cost in cents
        goals list                         List goals
        goals activate <id>                Activate a pending goal
        skills ls                          List available skills
        skills load <name>                 Load a skill prompt
    USAGE

    def initialize(client:, token:)
      @client = client
      @token = token
    end

    def run(argv)
      resource, command, *args = argv

      case [ resource, command ]
      in [ "tasks", "list" ]      then tasks_list
      in [ "tasks", "create" ]    then tasks_create(args[0], args[1..].join(" "))
      in [ "tasks", "claim" ]     then tasks_claim(args.first)
      in [ "tasks", "start" ]     then tasks_start(args.first)
      in [ "tasks", "complete" ]  then tasks_complete(args.first)
      in [ "tasks", "fail" ]      then tasks_fail(args.first)
      in [ "tasks", "message" ]   then tasks_message(args[0], args[1..].join(" "))
      in [ "tasks", "result" ]    then tasks_result(args[0], args[1..].join(" "))
      in [ "tasks", "relevance" ] then tasks_relevance(args[0], args[1])
      in [ "tasks", "cost" ]      then tasks_cost(args[0], args[1])
      in [ "goals", "list" ]      then goals_list
      in [ "goals", "activate" ]  then goals_activate(args.first)
      in [ "skills", "ls" ]       then skills_list
      in [ "skills", "load" ]     then skills_load(args.first)
      else
        puts USAGE
        exit 1
      end
    end

    private

    attr_reader :client, :token

    def tasks_list
      result = client.fetch_pending_tasks(agent_token: token)
      tasks = result.fetch(:tasks, [])
      if tasks.empty?
        puts "No pending tasks."
      else
        tasks.each { |t| puts "#{t[:id]}\t#{t[:title]}\t#{t[:status]}" }
      end
    end

    def tasks_create(goal_id, title)
      abort "goal id required" unless goal_id
      abort "title required" if title.nil? || title.empty?
      result = client.create_task(goal_id, title: title, agent_token: token)
      if result[:status] == "created"
        puts "Created task #{result.dig(:task, :id)} for goal #{goal_id}."
      else
        warn "Could not create task: #{result[:error]}"
        exit 1
      end
    end

    def tasks_claim(id)
      abort "task id required" unless id
      result = client.claim_task(id, agent_token: token)
      if result[:status] == "claimed"
        puts "Claimed task #{id}."
      else
        warn "Could not claim task #{id}: #{result[:error]}"
        exit 1
      end
    end

    def tasks_start(id)
      abort "task id required" unless id
      result = client.start_task(id, agent_token: token)
      if result[:status] == "started"
        puts "Started task #{id}."
      else
        warn "Could not start task #{id}: #{result[:error]}"
        exit 1
      end
    end

    def tasks_complete(id)
      abort "task id required" unless id
      result = client.complete_task(id, agent_token: token)
      if result[:status] == "completed"
        puts "Task #{id} marked complete."
      else
        warn "Could not complete task #{id}: #{result[:error]}"
        exit 1
      end
    end

    def tasks_fail(id)
      abort "task id required" unless id
      client.fail_task(id, error: "failed via CLI", agent_token: token)
      puts "Task #{id} marked failed."
    end

    def tasks_message(id, body)
      abort "task id required" unless id
      abort "message body required" if body.empty?
      client.post_message(id, body: body, agent_token: token)
      puts "Posted message to task #{id}."
    end

    def tasks_result(id, body)
      abort "task id required" unless id
      abort "result body required" if body.empty?
      client.post_result(id, body: body, agent_token: token)
      puts "Posted result to task #{id}."
    end

    def tasks_relevance(id, relevant_str)
      abort "task id required" unless id
      abort "relevance (true|false) required" unless %w[true false].include?(relevant_str)
      relevant = relevant_str == "true"
      client.report_relevance(id, relevant: relevant, agent_token: token)
      puts "Reported relevance=#{relevant} for task #{id}."
    end

    def tasks_cost(id, cents)
      abort "task id required" unless id
      abort "cost in cents required" unless cents
      client.report_cost(id, cost_cents: cents.to_i, agent_token: token)
      puts "Reported cost=#{cents} cents for task #{id}."
    end

    def goals_list
      result = client.fetch_goals
      goals = result.fetch(:goals, [])
      if goals.empty?
        puts "No goals."
      else
        goals.each { |g| puts "#{g[:id]}\t#{g[:status]}\t#{g[:title]}" }
      end
    end

    def goals_activate(id)
      abort "goal id required" unless id
      result = client.activate_goal(id)
      if result[:status] == "active"
        puts "Goal #{id} activated."
      else
        warn "Could not activate goal #{id}: #{result[:error]}"
        exit 1
      end
    end

    def skills_list
      result = client.fetch_skills(agent_token: token)
      skills = result.fetch(:skills, [])
      if skills.empty?
        puts "No skills assigned."
      else
        skills.each { |s| puts "#{s[:name]}\t#{s[:keywords]}\t#{s[:description]}" }
      end
    end

    def skills_load(name)
      abort "skill name required" unless name
      result = client.load_skill(name, agent_token: token)
      if result[:error]
        warn "Could not load skill #{name}: #{result[:error]}"
        exit 1
      else
        puts result.dig(:skill, :prompt)
      end
    end
  end
end
