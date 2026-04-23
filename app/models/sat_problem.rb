class SatProblem < ApplicationRecord
  serialize :clauses, coder: JSON

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :num_vars, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :satisfiable, inclusion: { in: [true, false] }
  validate :valid_clauses_structure

  def num_clauses
    clauses.length
  end

  private

  def valid_clauses_structure
    unless clauses.is_a?(Array) && clauses.any? && clauses.all? { |clause| valid_clause?(clause) }
      errors.add(:clauses, "must be an array of non-empty literal arrays")
    end
  end

  def valid_clause?(clause)
    clause.is_a?(Array) &&
      clause.any? &&
      clause.all? { |literal| literal.is_a?(Integer) && literal != 0 && literal.abs <= num_vars.to_i }
  end
end
