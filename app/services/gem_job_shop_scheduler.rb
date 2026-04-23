require "or-tools"

class GemJobShopScheduler
  REFERENCE_VERSION = "or-tools-cp-sat-job-shop-v1"

  Result = Data.define(:optimal_makespan, :scheduled_tasks, :source, :reference_version) do
    def to_h
      {
        optimal_makespan: optimal_makespan,
        scheduled_tasks: scheduled_tasks,
        source: source,
        reference_version: reference_version
      }
    end
  end

  def initialize(jobs)
    @jobs = jobs
    validate_jobs!
  end

  def solve
    horizon = @jobs.flat_map { |job| job.map { |task| task.fetch(1) } }.sum
    model = ORTools::CpModel.new
    task_vars = {}

    @jobs.each_with_index do |job, job_id|
      job.each_with_index do |(machine_id, duration), task_id|
        start_var = model.new_int_var(0, horizon, "start_#{job_id}_#{task_id}")
        end_var = model.new_int_var(0, horizon, "end_#{job_id}_#{task_id}")
        duration_var = model.new_constant(duration)
        interval_var = model.new_interval_var(start_var, duration_var, end_var, "interval_#{job_id}_#{task_id}")
        task_vars[[job_id, task_id]] = {
          start: start_var,
          end: end_var,
          interval: interval_var,
          machine_id: machine_id,
          duration: duration
        }
      end
    end

    @jobs.each_with_index do |job, job_id|
      job.each_cons(2).with_index do |_pair, task_id|
        model.add(task_vars.fetch([job_id, task_id + 1]).fetch(:start) >= task_vars.fetch([job_id, task_id]).fetch(:end))
      end
    end

    task_vars.values.group_by { |task| task.fetch(:machine_id) }.each_value do |tasks|
      model.add_no_overlap(tasks.map { |task| task.fetch(:interval) })
    end

    makespan = model.new_int_var(0, horizon, "makespan")
    task_vars.each_value do |task|
      model.add(makespan >= task.fetch(:end))
    end
    model.minimize(makespan)

    solver = ORTools::CpSolver.new
    status = solver.solve(model)
    raise "OR-Tools Cp-SAT failed with status #{status}" unless status == :optimal

    scheduled_tasks = @jobs.each_with_index.flat_map do |job, job_id|
      job.each_with_index.map do |(machine_id, duration), task_id|
        {
          job_id: job_id,
          task_id: task_id,
          machine_id: machine_id,
          duration: duration,
          start_time: solver.value(task_vars.fetch([job_id, task_id]).fetch(:start)),
          end_time: solver.value(task_vars.fetch([job_id, task_id]).fetch(:end))
        }
      end
    end.sort_by { |task| [task.fetch(:start_time), task.fetch(:machine_id), task.fetch(:job_id), task.fetch(:task_id)] }

    Result.new(
      optimal_makespan: solver.value(makespan),
      scheduled_tasks: scheduled_tasks,
      source: "or-tools",
      reference_version: REFERENCE_VERSION
    )
  end

  private

  def validate_jobs!
    unless @jobs.is_a?(Array) && @jobs.any?
      raise ArgumentError, "jobs must be a non-empty array"
    end
  end
end
