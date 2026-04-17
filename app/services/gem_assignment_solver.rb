require "or-tools"

class GemAssignmentSolver
  SCALE = 1000
  REFERENCE_VERSION = "or-tools-linear-sum-assignment-v1"

  Result = Data.define(:assignment, :cost, :source, :reference_version, :scaled_optimal_cost) do
    def to_h
      {
        assignment: assignment,
        cost: cost,
        source: source,
        reference_version: reference_version,
        scaled_optimal_cost: scaled_optimal_cost
      }
    end
  end

  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @n = cost_matrix.length
    validate_matrix!
  end

  def solve
    solver = ORTools::LinearSumAssignment.new

    @n.times do |worker|
      @n.times do |task|
        solver.add_arc_with_cost(worker, task, scaled_cost(@cost_matrix.fetch(worker).fetch(task)))
      end
    end

    status = solver.solve
    raise "OR-Tools LinearSumAssignment failed with status #{status}" unless status == :optimal

    assignment = @n.times.map { |worker| solver.right_mate(worker) }

    Result.new(
      assignment: assignment,
      cost: assignment.each_with_index.sum { |task, worker| @cost_matrix.fetch(worker).fetch(task) },
      source: "or-tools",
      reference_version: REFERENCE_VERSION,
      scaled_optimal_cost: solver.optimal_cost
    )
  end

  private

  def validate_matrix!
    unless @cost_matrix.is_a?(Array) &&
        @n.positive? &&
        @cost_matrix.all? { |row| row.is_a?(Array) && row.length == @n && row.all? { |cost| cost.is_a?(Numeric) } }
      raise ArgumentError, "cost matrix must be a non-empty square numeric matrix"
    end
  end

  def scaled_cost(cost)
    (cost * SCALE).round
  end
end
