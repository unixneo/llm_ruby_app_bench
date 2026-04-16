class Interpretation < ApplicationRecord
  belongs_to :attempt

  CLASSIFICATIONS = [
    "correct_match",
    "acceptable_approximation",
    "mathematical_or_algorithmic_error",
    "possible_goal_drift",
    "reference_limitation",
    "needs_another_fixture",
    "inconclusive"
  ].freeze

  validates :classification, presence: true, inclusion: { in: CLASSIFICATIONS }
end
