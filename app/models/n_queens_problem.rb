class NQueensProblem < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :n, presence: true, numericality: { only_integer: true, greater_than: 0 }
end

