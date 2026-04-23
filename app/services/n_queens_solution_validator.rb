class NQueensSolutionValidator
  def self.validate(problem, result)
    new(problem).validate(result)
  end

  def initialize(problem)
    @problem = problem
  end

  def validate(result)
    errors = []
    n = @problem.n

    errors << "n mismatch: expected #{n}, got #{result.n}" unless result.n == n
    errors << "Count must be nonnegative integer" unless result.count.is_a?(Integer) && result.count >= 0

    if n <= 10
      unless result.solutions.is_a?(Array)
        errors << "Solutions must be array for n <= 10"
      end

      if result.solutions.is_a?(Array)
        errors << "solutions.size mismatch: expected #{result.count}, got #{result.solutions.size}" unless result.solutions.size == result.count
        result.solutions.each_with_index do |placement, index|
          validate_placement(placement, n, index, errors)
        end
      end
    end

    {
      valid: errors.empty?,
      errors: errors
    }
  end

  private

  def validate_placement(placement, n, index, errors)
    unless placement.is_a?(Array) && placement.length == n
      errors << "Solution #{index} must be an array of length #{n}"
      return
    end

    unless placement.all? { |column| column.is_a?(Integer) && column.between?(0, n - 1) }
      errors << "Solution #{index} has invalid column value"
      return
    end

    errors << "Solution #{index} has duplicate columns" unless placement.uniq.length == n

    main_diagonals = {}
    anti_diagonals = {}
    placement.each_with_index do |column, row|
      main_key = row - column
      anti_key = row + column

      errors << "Solution #{index} has main diagonal conflict" if main_diagonals.key?(main_key)
      errors << "Solution #{index} has anti diagonal conflict" if anti_diagonals.key?(anti_key)

      main_diagonals[main_key] = true
      anti_diagonals[anti_key] = true
    end
  end
end
