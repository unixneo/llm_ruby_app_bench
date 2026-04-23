class SatSolutionValidator
  def self.validate(problem, result)
    new(problem).validate(result)
  end

  def initialize(problem)
    @problem = problem
  end

  def validate(result)
    errors = []

    errors << "num_vars mismatch: expected #{@problem.num_vars}, got #{result.num_vars}" unless result.num_vars == @problem.num_vars
    errors << "clauses mismatch" unless result.clauses == @problem.clauses
    errors << "satisfiable must be boolean" unless [true, false].include?(result.satisfiable)

    if result.satisfiable
      validate_sat_result(result, errors)
    else
      errors << "assignments must be nil for UNSAT results" unless result.assignments.nil?
    end

    {
      valid: errors.empty?,
      errors: errors
    }
  end

  private

  def validate_sat_result(result, errors)
    assignments = result.assignments
    unless assignments.is_a?(Hash)
      errors << "assignments must be a hash for SAT results"
      return
    end

    expected_vars = (1..@problem.num_vars).to_a
    missing_vars = expected_vars.reject { |var| assignments.key?(var) }
    errors << "missing assignments for variables: #{missing_vars.join(", ")}" unless missing_vars.empty?

    non_boolean_vars = assignments.select { |_var, value| ![true, false].include?(value) }.keys
    errors << "assignments must be boolean for variables: #{non_boolean_vars.join(", ")}" unless non_boolean_vars.empty?

    solver = SatSolver.new(@problem.num_vars, @problem.clauses)
    errors << "assignment does not satisfy all clauses" unless solver.valid_assignment?(assignments, @problem.clauses)
  end
end
