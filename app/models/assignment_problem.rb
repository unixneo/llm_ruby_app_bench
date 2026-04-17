class AssignmentProblem < ApplicationRecord
  serialize :cost_matrix, coder: JSON

  validates :name, presence: true, uniqueness: true
  validates :workers, :tasks, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :cost_matrix_dimensions
  validate :square_matrix

  private

  def cost_matrix_dimensions
    return if workers.blank? || tasks.blank?

    unless cost_matrix.is_a?(Array) &&
        cost_matrix.length == workers &&
        cost_matrix.all? { |row| row.is_a?(Array) && row.length == tasks && row.all? { |cost| cost.is_a?(Numeric) } }
      errors.add(:cost_matrix, "must be a #{workers}x#{tasks} numeric matrix")
    end
  end

  def square_matrix
    return if workers.blank? || tasks.blank?

    errors.add(:tasks, "must equal workers for one-to-one assignment") unless workers == tasks
  end
end
