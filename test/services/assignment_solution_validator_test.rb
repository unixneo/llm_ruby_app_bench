require "test_helper"

class AssignmentSolutionValidatorTest < ActiveSupport::TestCase
  test "accepts valid one to one assignment" do
    matrix = [[9, 2, 7], [6, 4, 3], [5, 8, 1]]
    result = AssignmentSolutionValidator.validate(matrix, [1, 0, 2], 9)

    assert result.fetch(:valid)
    assert_empty result.fetch(:errors)
    assert_equal 9, result.fetch(:actual_cost)
  end

  test "rejects duplicate task assignment" do
    matrix = [[9, 2, 7], [6, 4, 3], [5, 8, 1]]
    result = AssignmentSolutionValidator.validate(matrix, [1, 1, 2], 7)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Tasks not uniquely assigned"
  end

  test "rejects cost mismatch" do
    matrix = [[9, 2, 7], [6, 4, 3], [5, 8, 1]]
    result = AssignmentSolutionValidator.validate(matrix, [1, 0, 2], 10)

    refute result.fetch(:valid)
    assert_includes result.fetch(:errors), "Cost mismatch: reported 10, actual 9"
  end
end
