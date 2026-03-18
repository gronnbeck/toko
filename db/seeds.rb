# -- Organization --
org = Organization.find_or_create_by!(name: "Toko HQ")
Prompt.find_or_create_by!(promptable: org, kind: :mission) do |p|
  p.body = "Coordinate autonomous agents to complete engineering tasks efficiently."
end
Prompt.find_or_create_by!(promptable: org, kind: :policy) do |p|
  p.body = "Agents must claim tasks before starting. Report failures immediately."
end

# -- Agents --
agents_data = [
  { name: "Alpha",   status: :online,  mission: "Triage incoming tasks and delegate work." },
  { name: "Bravo",   status: :busy,    mission: "Execute code changes and run tests." },
  { name: "Charlie", status: :offline,  mission: "Monitor deployments and rollback on failure." }
]

agents = agents_data.map do |attrs|
  agent = Agent.find_or_create_by!(name: attrs[:name]) do |a|
    a.status = attrs[:status]
    a.organization = org
  end
  agent.update!(organization: org) unless agent.organization == org

  Prompt.find_or_create_by!(promptable: agent, kind: :mission) do |p|
    p.body = attrs[:mission]
  end
  agent
end

# -- Tasks --
[
  { title: "Analyse error logs from production", status: :pending },
  { title: "Write summary report for last sprint", status: :in_progress, claimed_by: agents.first },
  { title: "Update dependencies", status: :completed },
  { title: "Deploy hotfix to staging", status: :failed }
].each do |attrs|
  Task.find_or_create_by!(title: attrs[:title]) do |t|
    t.status = attrs[:status]
    t.claimed_by = attrs[:claimed_by]
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
puts ""
agents.each { |a| puts "  Agent #{a.name} (#{a.token}) — #{a.status}" }
puts ""
puts "Tasks: #{Task.count} (#{Task.group(:status).count.map { |s, c| "#{s}: #{c}" }.join(', ')})"
puts ""
puts "Wrote #{settings_path}"
puts "Start the server, then run:  bin/harness harness/settings.yml"
