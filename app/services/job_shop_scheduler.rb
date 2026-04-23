class JobShopScheduler
  SOURCE = "branch-and-bound"

  Task = Data.define(:job_id, :task_id, :machine_id, :duration, :id)
  Result = Data.define(:optimal_makespan, :scheduled_tasks, :source, :iterations) do
    def to_h
      {
        optimal_makespan: optimal_makespan,
        scheduled_tasks: scheduled_tasks,
        source: source,
        iterations: iterations
      }
    end
  end

  def initialize(jobs)
    @jobs = jobs
    validate_jobs!
    build_tasks
  end

  def solve
    @iterations = 0
    @best_makespan = greedy_upper_bound.fetch(:optimal_makespan)
    @best_schedule = greedy_upper_bound.fetch(:scheduled_tasks).each_with_object({}) do |task, memo|
      memo[[task.fetch(:job_id), task.fetch(:task_id)]] = task.fetch(:start_time)
    end

    search(
      job_next: Array.new(@jobs.length, 0),
      job_ready: Array.new(@jobs.length, 0),
      machine_ready: Array.new(@machine_count, 0),
      start_times: {},
      current_makespan: 0
    )

    Result.new(
      optimal_makespan: @best_makespan,
      scheduled_tasks: formatted_schedule(@best_schedule),
      source: SOURCE,
      iterations: @iterations
    )
  end

  private

  def validate_jobs!
    unless @jobs.is_a?(Array) && @jobs.any? && @jobs.all? { |job| valid_job?(job) }
      raise ArgumentError, "jobs must be an array of jobs containing [machine_id, duration] integer pairs"
    end
  end

  def valid_job?(job)
    job.is_a?(Array) &&
      job.any? &&
      job.all? do |task|
        task.is_a?(Array) &&
          task.length == 2 &&
          task.all? { |value| value.is_a?(Integer) } &&
          task.fetch(0) >= 0 &&
          task.fetch(1) > 0
      end
  end

  def build_tasks
    @tasks_by_job = @jobs.each_with_index.map do |job, job_id|
      job.each_with_index.map do |(machine_id, duration), task_id|
        Task.new(
          job_id: job_id,
          task_id: task_id,
          machine_id: machine_id,
          duration: duration,
          id: [job_id, task_id]
        )
      end
    end
    @machine_count = @tasks_by_job.flatten.map(&:machine_id).max + 1
  end

  def greedy_upper_bound
    job_next = Array.new(@jobs.length, 0)
    job_ready = Array.new(@jobs.length, 0)
    machine_ready = Array.new(@machine_count, 0)
    start_times = {}
    current_makespan = 0

    until completed?(job_next)
      available = available_tasks(job_next)
      est_map = earliest_starts(available, job_ready, machine_ready)
      selected = available.min_by { |task| [est_map.fetch(task.id) + task.duration, est_map.fetch(task.id), task.duration, task.job_id] }
      start_time = est_map.fetch(selected.id)
      end_time = start_time + selected.duration

      start_times[selected.id] = start_time
      job_next[selected.job_id] += 1
      job_ready[selected.job_id] = end_time
      machine_ready[selected.machine_id] = end_time
      current_makespan = [current_makespan, end_time].max
    end

    {
      optimal_makespan: current_makespan,
      scheduled_tasks: formatted_schedule(start_times)
    }
  end

  def search(job_next:, job_ready:, machine_ready:, start_times:, current_makespan:)
    @iterations += 1

    if completed?(job_next)
      if current_makespan < @best_makespan
        @best_makespan = current_makespan
        @best_schedule = start_times.dup
      end
      return
    end

    lower_bound = lower_bound(job_next, job_ready, machine_ready, current_makespan)
    return if lower_bound >= @best_makespan

    available = available_tasks(job_next)
    est_map = earliest_starts(available, job_ready, machine_ready)
    selected = available.min_by { |task| [est_map.fetch(task.id) + task.duration, est_map.fetch(task.id), task.duration, task.job_id] }
    selected_completion = est_map.fetch(selected.id) + selected.duration

    conflict_set = available.select do |task|
      task.machine_id == selected.machine_id && est_map.fetch(task.id) < selected_completion
    end
    conflict_set.sort_by! { |task| [est_map.fetch(task.id), task.duration, task.job_id, task.task_id] }

    conflict_set.each do |task|
      start_time = est_map.fetch(task.id)
      end_time = start_time + task.duration

      next_job_next = job_next.dup
      next_job_ready = job_ready.dup
      next_machine_ready = machine_ready.dup
      next_start_times = start_times.dup

      next_start_times[task.id] = start_time
      next_job_next[task.job_id] += 1
      next_job_ready[task.job_id] = end_time
      next_machine_ready[task.machine_id] = end_time

      search(
        job_next: next_job_next,
        job_ready: next_job_ready,
        machine_ready: next_machine_ready,
        start_times: next_start_times,
        current_makespan: [current_makespan, end_time].max
      )
    end
  end

  def completed?(job_next)
    job_next.each_with_index.all? { |next_index, job_id| next_index >= @tasks_by_job.fetch(job_id).length }
  end

  def available_tasks(job_next)
    job_next.each_with_index.filter_map do |next_index, job_id|
      @tasks_by_job.fetch(job_id)[next_index]
    end
  end

  def earliest_starts(available, job_ready, machine_ready)
    available.each_with_object({}) do |task, memo|
      memo[task.id] = [job_ready.fetch(task.job_id), machine_ready.fetch(task.machine_id)].max
    end
  end

  def lower_bound(job_next, job_ready, machine_ready, current_makespan)
    job_bound = @tasks_by_job.each_with_index.map do |tasks, job_id|
      remaining = tasks.drop(job_next.fetch(job_id)).sum(&:duration)
      job_ready.fetch(job_id) + remaining
    end.max || 0

    machine_bound = Array.new(@machine_count, 0).map.with_index do |_value, machine_id|
      remaining = @tasks_by_job.flatten.select do |task|
        task.machine_id == machine_id && task.task_id >= job_next.fetch(task.job_id)
      end.sum(&:duration)
      machine_ready.fetch(machine_id) + remaining
    end.max || 0

    [current_makespan, job_bound, machine_bound].max
  end

  def formatted_schedule(start_times)
    @tasks_by_job.flatten.map do |task|
      start_time = start_times.fetch(task.id)
      {
        job_id: task.job_id,
        task_id: task.task_id,
        machine_id: task.machine_id,
        duration: task.duration,
        start_time: start_time,
        end_time: start_time + task.duration
      }
    end.sort_by { |task| [task.fetch(:start_time), task.fetch(:machine_id), task.fetch(:job_id), task.fetch(:task_id)] }
  end
end
