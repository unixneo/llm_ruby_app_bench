#!/usr/bin/env ruby
# Verification script: Confirms candidate solvers are pure Ruby, reference solvers use OR-Tools

puts "=" * 70
puts "SOLVER COMPARISON ARCHITECTURE VERIFICATION"
puts "=" * 70
puts

# Define the solvers to check
candidate_solvers = [
  "app/services/tsp_solver.rb",
  "app/services/nearest_neighbor_solver.rb", 
  "app/services/held_karp_solver.rb",
  "app/services/vrp_solver.rb",
  "app/services/assignment_solver.rb",
  "app/services/max_flow_solver.rb"
]

reference_solvers = [
  "app/services/gem_tsp_solver.rb",
  "app/services/gem_vrp_solver.rb",
  "app/services/gem_assignment_solver.rb",
  "app/services/gem_max_flow_solver.rb"
]

def check_for_or_tools(filepath)
  return { exists: false } unless File.exist?(filepath)
  
  content = File.read(filepath)
  has_require = content.match?(/require\s+['"](or-tools|google\/ortools)['"]/)
  has_ortools_ref = content.match?(/ORTools|Google::OrTools/)
  
  { 
    exists: true, 
    has_or_tools: has_require || has_ortools_ref,
    line_count: content.lines.count
  }
end

puts "CANDIDATE SOLVERS (Pure Ruby - should NOT use OR-Tools):"
puts "-" * 70

violations = []
candidate_solvers.each do |solver|
  result = check_for_or_tools(solver)
  if !result[:exists]
    puts "  ⚠️  #{solver}: FILE NOT FOUND"
  elsif result[:has_or_tools]
    puts "  ❌ #{solver}: USES OR-TOOLS (VIOLATION!)"
    violations << solver
  else
    puts "  ✅ #{solver}: Pure Ruby (#{result[:line_count]} lines)"
  end
end

puts
puts "REFERENCE SOLVERS (OR-Tools - MUST use OR-Tools):"
puts "-" * 70

missing_or_tools = []
reference_solvers.each do |solver|
  result = check_for_or_tools(solver)
  if !result[:exists]
    puts "  ⚠️  #{solver}: FILE NOT FOUND"
  elsif !result[:has_or_tools]
    puts "  ❌ #{solver}: MISSING OR-TOOLS (VIOLATION!)"
    missing_or_tools << solver
  else
    puts "  ✅ #{solver}: Uses OR-Tools (#{result[:line_count]} lines)"
  end
end

puts
puts "=" * 70
puts "VERIFICATION SUMMARY"
puts "=" * 70

if violations.empty? && missing_or_tools.empty?
  puts "✅ PASS: All candidate solvers are pure Ruby"
  puts "✅ PASS: All reference solvers use OR-Tools"
  puts
  puts "Architecture is correct:"
  puts "  - Candidate solvers: Pure Ruby implementations"
  puts "  - Reference solvers: OR-Tools gem wrappers"
  puts "  - No cross-contamination detected"
  exit 0
else
  puts "❌ FAIL: Architecture violations detected!"
  puts
  
  if violations.any?
    puts "Candidate solvers using OR-Tools (SHOULD BE PURE RUBY):"
    violations.each { |v| puts "  - #{v}" }
    puts
  end
  
  if missing_or_tools.any?
    puts "Reference solvers NOT using OR-Tools (SHOULD USE OR-TOOLS):"
    missing_or_tools.each { |v| puts "  - #{v}" }
    puts
  end
  
  puts "Fix these violations before considering results valid!"
  exit 1
end
