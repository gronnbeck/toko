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

# -- Skills --
skills_data = [
  { name: "task-decomposition", keywords: "planning breakdown scoping",
    description: "Break goals into well-scoped, actionable tasks",
    prompt: "When decomposing goals into tasks:\n" \
            "- Each task should be completable in one work session\n" \
            "- Include clear acceptance criteria\n" \
            "- Identify dependencies between tasks\n" \
            "- Prefer small, focused tasks over large ones" },
  { name: "prioritization", keywords: "priority ordering triage",
    description: "Prioritize tasks by impact and urgency",
    prompt: "When prioritizing tasks:\n" \
            "- Consider goal deadlines and dependencies\n" \
            "- Blocked tasks should not be prioritized over unblocked ones\n" \
            "- Balance quick wins with high-impact work\n" \
            "- Re-evaluate priorities when new goals arrive" },
  { name: "rails-conventions", keywords: "ruby rails patterns",
    description: "Follow Rails and project coding conventions",
    prompt: "Follow these Rails conventions:\n" \
            "- Use service objects (ModuleName::ClassName.call) for business logic\n" \
            "- Keep controllers thin, models focused\n" \
            "- Use Phlex for all view components\n" \
            "- Max ~120 lines per file, max 7 methods\n" \
            "- Prefer module_function over instance methods in services" },
  { name: "testing-patterns", keywords: "tests tdd minitest",
    description: "Write effective tests following project patterns",
    prompt: "Follow these testing patterns:\n" \
            "- Red-Green-Commit: write failing test, implement, commit\n" \
            "- Use Minitest (not RSpec)\n" \
            "- Test files mirror source structure under test/\n" \
            "- Keep test files under ~120 lines\n" \
            "- Run bin/ci before every commit" },
  { name: "refactoring", keywords: "cleanup simplify extract",
    description: "Improve code structure without changing behavior",
    prompt: "When refactoring:\n" \
            "- Ensure tests pass before and after changes\n" \
            "- Extract methods when a method exceeds 10 lines\n" \
            "- Replace conditionals with polymorphism when appropriate\n" \
            "- Remove dead code rather than commenting it out\n" \
            "- Keep commits small and focused on one refactoring at a time" },
  { name: "code-review-checklist", keywords: "review quality checks",
    description: "Systematic code review checklist",
    prompt: "Code review checklist:\n" \
            "- Tests exist and pass for new/changed behavior\n" \
            "- No security vulnerabilities (check OWASP top 10)\n" \
            "- Follows project conventions (service objects, Phlex views)\n" \
            "- Files stay under ~120 lines, methods under 10 lines\n" \
            "- No unnecessary complexity or premature abstractions\n" \
            "- Commit messages are clear and descriptive" },
  { name: "deployment-checklist", keywords: "deploy kamal production",
    description: "Pre-deployment verification steps",
    prompt: "Before deploying:\n" \
            "- All tests pass (bin/ci green)\n" \
            "- Migrations are reversible\n" \
            "- No pending migrations in production\n" \
            "- Check for N+1 queries in new code\n" \
            "- Verify Docker build succeeds locally\n" \
            "- Review Kamal deploy.yml for any config changes" },
  { name: "incident-response", keywords: "outage alert rollback",
    description: "Handle production incidents and alerts",
    prompt: "During an incident:\n" \
            "- Assess severity and impact immediately\n" \
            "- Rollback first if the cause is a recent deploy\n" \
            "- Check logs and error monitoring for root cause\n" \
            "- Post status updates as progress messages\n" \
            "- After resolution, create a task for post-mortem" }
]

agent_map = agents.index_by(&:name)
skill_assignments = {
  "task-decomposition" => %w[Planner],
  "prioritization" => %w[Planner],
  "rails-conventions" => %w[Coder Reviewer],
  "testing-patterns" => %w[Coder Tester],
  "refactoring" => %w[Coder Reviewer],
  "code-review-checklist" => %w[Reviewer],
  "deployment-checklist" => %w[Ops],
  "incident-response" => %w[Ops]
}

skills_data.each do |attrs|
  skill = Skill.find_or_create_by!(name: attrs[:name]) do |s|
    s.keywords = attrs[:keywords]
    s.description = attrs[:description]
  end
  Prompt.find_or_create_by!(promptable: skill, kind: :skill) do |p|
    p.body = attrs[:prompt]
  end
  skill_assignments.fetch(attrs[:name], []).each do |agent_name|
    AgentSkill.find_or_create_by!(agent: agent_map[agent_name], skill: skill)
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
  skill_names = a.skills.pluck(:name).join(", ")
  puts "  Agent #{a.name} (#{a.token}) — daily_budget: #{a.daily_budget_cents}c — skills: #{skill_names}"
end
puts ""
puts "Wrote #{settings_path}"
puts "Start the server, then run:  bin/harness harness/settings.yml"
