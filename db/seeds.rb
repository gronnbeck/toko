[
  { title: "Analyse error logs from production", status: :pending },
  { title: "Write summary report for last sprint", status: :in_progress },
  { title: "Update dependencies", status: :completed },
  { title: "Deploy hotfix to staging", status: :failed }
].each do |attrs|
  Task.find_or_create_by!(title: attrs[:title]) { |t| t.status = attrs[:status] }
end
