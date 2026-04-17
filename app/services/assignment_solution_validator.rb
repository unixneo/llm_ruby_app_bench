class AssignmentSolutionValidator
  TOLERANCE = 0.01

  def self.validate(cost_matrix, assignment, reported_cost)
    new(cost_matrix).validate(assignment, reported_cost)
  end

  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @n = cost_matrix.length
  end

  def validate(assignment, reported_cost)
    errors = []

    unless assignment.is_a?(Array)
      return { valid: false, errors: ["Assignment must be an array"], actual_cost: nil }
    end

    errors << "Assignment length mismatch" unless assignment.length == @n
    errors << "Not all workers assigned" unless assignment.all? { |task| task.is_a?(Integer) && task >= 0 && task < @n }
    errors << "Tasks not uniquely assigned" unless assignment.uniq.length == @n

    actual_cost = nil
    if errors.empty?
      actual_cost = assignment.each_with_index.sum { |task, worker| @cost_matrix.fetch(worker).fetch(task) }
      if reported_cost.nil? || (actual_cost - reported_cost).abs > TOLERANCE
        errors << "Cost mismatch: reported #{reported_cost}, actual #{actual_cost}"
      end
    end

    {
      valid: errors.empty?,
      errors: errors,
      actual_cost: actual_cost
    }
  end
end
