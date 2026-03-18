# -- Organization --
org = Organization.find_or_create_by!(name: "Toko Dev")
Prompt.find_or_create_by!(promptable: org, kind: :mission) do |p|
  p.body = "Build and maintain Toko as an autonomous software organization. " \
           "Ship features, fix bugs, and improve infrastructure continuously."
end
Prompt.find_or_create_by!(promptable: org, kind: :policy) do |p|
  p.body = "Agents must claim tasks before starting work. " \
           "Report costs after completing or failing a task. " \
           "Stay within your daily budget. " \
           "Post progress messages for long-running tasks."
end

# -- Budget --
budget = Budget.find_or_create_by!(organization: org) do |b|
  b.amount_cents = 10_000
end

# -- Agents --
agents_data = [
  { name: "Planner", daily_budget_cents: 2000,
    mission: "Read pending goals and decompose them into actionable tasks. " \
             "Prioritize work based on goal status and dependencies. " \
             "Create clear, well-scoped task descriptions." },
  { name: "Coder", daily_budget_cents: 3000,
    mission: "Implement features and fixes by writing clean, tested code. " \
             "Follow project conventions and keep changes small and focused. " \
             "Commit after each passing test cycle." },
  { name: "Tester", daily_budget_cents: 2000,
    mission: "Write and run tests to validate implementations. " \
             "Ensure adequate coverage for new features and bug fixes. " \
             "Report test failures with clear reproduction steps." },
  { name: "Reviewer", daily_budget_cents: 1500,
    mission: "Review completed work for correctness and code quality. " \
             "Check that tests pass and conventions are followed. " \
             "Provide constructive feedback or approve work." },
  { name: "Ops", daily_budget_cents: 1500,
    mission: "Handle deployments, monitoring, and infrastructure tasks. " \
             "Ensure the application is running correctly in production. " \
             "Respond to alerts and perform rollbacks when needed." }
]

agents = agents_data.map do |attrs|
  agent = Agent.find_or_create_by!(name: attrs[:name]) do |a|
    a.status = :online
    a.organization = org
    a.daily_budget_cents = attrs[:daily_budget_cents]
  end
  agent.update!(organization: org) unless agent.organization == org

  Prompt.find_or_create_by!(promptable: agent, kind: :mission) do |p|
    p.body = attrs[:mission]
  end
  agent
end

# -- Goals --
goals = [
  { title: "Implement agent cost dashboard",
    description: "Add a UI page showing per-agent spending, daily limits, and budget remaining." },
  { title: "Add task prioritization system",
    description: "Implement priority levels for tasks so agents work on the most important items first." }
].map do |attrs|
  Goal.find_or_create_by!(title: attrs[:title], organization: org) do |g|
    g.description = attrs[:description]
  end
end

# -- Tasks --
[
  { title: "Design cost dashboard wireframe", goal: goals[0] },
  { title: "Create CostSummary service", goal: goals[0] },
  { title: "Build dashboard Phlex view", goal: goals[0] },
  { title: "Add priority column to tasks", goal: goals[1] },
  { title: "Update task sorting by priority", goal: goals[1] }
].each do |attrs|
  Task.find_or_create_by!(title: attrs[:title]) do |t|
    t.goal = attrs[:goal]
  end
end

# -- Harness settings --
settings_path = Rails.root.join("harness/settings.yml")
yaml = {
  "server_url" => "http://localhost:3360",
  "poll_interval_seconds" => 5,
  "ping_interval_seconds" => 30,
  "agents" => {
    "max_concurrent" => agents.size,
    "tokens" => agents.map(&:token)
  }
}
File.write(settings_path, yaml.to_yaml)

# -- Summary --
puts "\n== Seed Summary =="
puts "Organization: #{org.name}"
puts "  Mission: #{org.mission&.body}"
puts "  Policy:  #{org.policy&.body}"
puts "  Budget:  #{budget.amount_cents} cents (#{budget.currency})"
puts ""
agents.each do |a|
  puts "  Agent #{a.name} (#{a.token}) — daily_budget: #{a.daily_budget_cents}c"
end
puts ""
puts "Goals: #{Goal.count}"
Goal.all.each { |g| puts "  [#{g.status}] #{g.title}" }
puts ""
puts "Tasks: #{Task.count} (#{Task.group(:status).count.map { |s, c| "#{s}: #{c}" }.join(', ')})"
puts ""
puts "Wrote #{settings_path}"
puts "Start the server, then run:  bin/harness harness/settings.yml"
