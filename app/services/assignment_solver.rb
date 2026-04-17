class AssignmentSolver
  SOURCE = "hungarian"

  Result = Data.define(:assignment, :cost, :source) do
    def to_h
      {
        assignment: assignment,
        cost: cost,
        source: source
      }
    end
  end

  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @n = cost_matrix.length
    validate_matrix!
  end

  def solve
    assignment = hungarian_assignment

    Result.new(
      assignment: assignment,
      cost: assignment.each_with_index.sum { |task, worker| @cost_matrix.fetch(worker).fetch(task) },
      source: SOURCE
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

  def hungarian_assignment
    # Shortest augmenting path form of the Hungarian algorithm for minimization.
    worker_potential = Array.new(@n + 1, 0.0)
    task_potential = Array.new(@n + 1, 0.0)
    matched_worker_for_task = Array.new(@n + 1, 0)
    previous_task = Array.new(@n + 1, 0)

    (1..@n).each do |worker|
      matched_worker_for_task[0] = worker
      current_task = 0
      min_slack = Array.new(@n + 1, Float::INFINITY)
      used_task = Array.new(@n + 1, false)

      loop do
        used_task[current_task] = true
        current_worker = matched_worker_for_task.fetch(current_task)
        delta = Float::INFINITY
        next_task = 0

        (1..@n).each do |task|
          next if used_task.fetch(task)

          slack = @cost_matrix.fetch(current_worker - 1).fetch(task - 1) -
            worker_potential.fetch(current_worker) -
            task_potential.fetch(task)

          if slack < min_slack.fetch(task)
            min_slack[task] = slack
            previous_task[task] = current_task
          end

          if min_slack.fetch(task) < delta
            delta = min_slack.fetch(task)
            next_task = task
          end
        end

        (0..@n).each do |task|
          if used_task.fetch(task)
            worker_potential[matched_worker_for_task.fetch(task)] += delta
            task_potential[task] -= delta
          else
            min_slack[task] -= delta
          end
        end

        current_task = next_task
        break if matched_worker_for_task.fetch(current_task).zero?
      end

      loop do
        prior_task = previous_task.fetch(current_task)
        matched_worker_for_task[current_task] = matched_worker_for_task.fetch(prior_task)
        current_task = prior_task
        break if current_task.zero?
      end
    end

    assignment = Array.new(@n)
    (1..@n).each do |task|
      worker = matched_worker_for_task.fetch(task)
      assignment[worker - 1] = task - 1 if worker.positive?
    end
    assignment
  end
end
