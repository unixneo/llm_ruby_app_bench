require "ravensat"

class GemSatSolver
  REFERENCE_VERSION = "ravensat-v1.1.1"

  Result = Data.define(:num_vars, :clauses, :satisfiable, :assignments, :source, :reference_version) do
    def to_h
      {
        num_vars: num_vars,
        clauses: clauses,
        satisfiable: satisfiable,
        assignments: assignments,
        source: source,
        reference_version: reference_version
      }
    end
  end

  def initialize(num_vars, clauses)
    @num_vars = num_vars
    @clauses = deep_dup(clauses)
  end

  def solve
    if @clauses.any?(&:empty?)
      return Result.new(
        num_vars: @num_vars,
        clauses: deep_dup(@clauses),
        satisfiable: false,
        assignments: nil,
        source: "ravensat",
        reference_version: REFERENCE_VERSION
      )
    end

    vars = (1..@num_vars).map { Ravensat::VarNode.new }
    formula = build_formula(vars)
    satisfiable = formula.nil? ? true : Ravensat::Solver.new.solve(formula)

    assignments = if satisfiable
      vars.each_with_index.to_h do |var, index|
        [index + 1, var.result == true]
      end
    end

    Result.new(
      num_vars: @num_vars,
      clauses: deep_dup(@clauses),
      satisfiable: satisfiable,
      assignments: assignments,
      source: "ravensat",
      reference_version: REFERENCE_VERSION
    )
  end

  private

  def build_formula(vars)
    clause_nodes = @clauses.map do |clause|
      nodes = clause.map do |literal|
        literal.positive? ? vars[literal - 1] : ~vars[-literal - 1]
      end
      nodes.reduce(:|)
    end

    clause_nodes.reduce(:&)
  end

  def deep_dup(clauses)
    clauses.map(&:dup)
  end
end
