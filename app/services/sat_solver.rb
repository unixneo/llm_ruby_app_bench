class SatSolver
  SOURCE = "dpll"

  Result = Data.define(:num_vars, :clauses, :satisfiable, :assignments, :decisions, :method, :source) do
    def to_h
      {
        num_vars: num_vars,
        clauses: clauses,
        satisfiable: satisfiable,
        assignments: assignments,
        decisions: decisions,
        method: method,
        source: source
      }
    end
  end

  def initialize(num_vars, clauses)
    @num_vars = num_vars
    @clauses = deep_dup(clauses)
    @decision_count = 0
  end

  def solve
    satisfiable, assignment = dpll(@clauses, {})
    normalized_assignment = satisfiable ? finalize_assignment(assignment) : nil

    Result.new(
      num_vars: @num_vars,
      clauses: deep_dup(@clauses),
      satisfiable: satisfiable,
      assignments: normalized_assignment,
      decisions: @decision_count,
      method: :dpll,
      source: SOURCE
    )
  end

  def valid_assignment?(assignments, clauses = @clauses)
    return false unless assignments.is_a?(Hash)

    clauses.all? do |clause|
      clause.any? do |literal|
        variable = literal.abs
        value = assignments[variable]
        value = assignments[variable.to_s] if value.nil?
        literal.positive? ? value == true : value == false
      end
    end
  end

  private

  def dpll(clauses, assignment)
    propagated = propagate(clauses, assignment)
    return [false, nil] unless propagated.fetch(:ok)

    clauses = propagated.fetch(:clauses)
    assignment = propagated.fetch(:assignment)

    return [true, assignment] if clauses.empty?
    return [false, nil] if clauses.any?(&:empty?)

    variable = choose_variable(clauses)
    @decision_count += 1

    [true, false].each do |value|
      branch_assignment = assignment.merge(variable => value)
      branch_clauses = simplify_clauses(clauses, variable, value)
      satisfiable, solved_assignment = dpll(branch_clauses, branch_assignment)
      return [true, solved_assignment] if satisfiable
    end

    [false, nil]
  end

  def propagate(initial_clauses, initial_assignment)
    clauses = deep_dup(initial_clauses)
    assignment = initial_assignment.dup

    loop do
      unit_literal = clauses.find { |clause| clause.length == 1 }&.first
      if unit_literal
        variable = unit_literal.abs
        value = unit_literal.positive?
        if assignment.key?(variable) && assignment[variable] != value
          return { ok: false, clauses: clauses, assignment: assignment }
        end

        assignment[variable] = value
        clauses = simplify_clauses(clauses, variable, value)
        return { ok: false, clauses: clauses, assignment: assignment } if clauses.any?(&:empty?)
        next
      end

      pure_literals = find_pure_literals(clauses)
      break if pure_literals.empty?

      pure_literals.each do |variable, value|
        next if assignment.key?(variable)

        assignment[variable] = value
        clauses = simplify_clauses(clauses, variable, value)
        return { ok: false, clauses: clauses, assignment: assignment } if clauses.any?(&:empty?)
      end
    end

    { ok: true, clauses: clauses, assignment: assignment }
  end

  def find_pure_literals(clauses)
    polarity_by_var = Hash.new { |hash, key| hash[key] = {} }

    clauses.each do |clause|
      clause.each do |literal|
        variable = literal.abs
        polarity_by_var[variable][literal.positive?] = true
      end
    end

    polarity_by_var.each_with_object({}) do |(variable, polarities), memo|
      next unless polarities.length == 1

      memo[variable] = polarities.key?(true)
    end
  end

  def choose_variable(clauses)
    clauses.each do |clause|
      clause.each do |literal|
        return literal.abs
      end
    end

    raise "No variable available for branching"
  end

  def simplify_clauses(clauses, variable, value)
    clauses.each_with_object([]) do |clause, reduced|
      if clause.any? { |literal| literal_matches_assignment?(literal, variable, value) }
        next
      end

      filtered = clause.reject { |literal| literal_contradicts_assignment?(literal, variable, value) }
      reduced << filtered
    end
  end

  def literal_matches_assignment?(literal, variable, value)
    literal.abs == variable && (literal.positive? ? value : !value)
  end

  def literal_contradicts_assignment?(literal, variable, value)
    literal.abs == variable && (literal.positive? ? !value : value)
  end

  def finalize_assignment(partial_assignment)
    (1..@num_vars).each_with_object({}) do |variable, complete|
      complete[variable] = partial_assignment.fetch(variable, false)
    end
  end

  def deep_dup(clauses)
    clauses.map(&:dup)
  end
end
