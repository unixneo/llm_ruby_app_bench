class JobShopScheduleValidator
  TOLERANCE = 0.01

  def self.validate(jobs, scheduled_tasks, reported_makespan)
    new(jobs).validate(scheduled_tasks, reported_makespan)
  end

  def initialize(jobs)
    @jobs = jobs
  end

  def validate(scheduled_tasks, reported_makespan)
    errors = []
    expected_task_count = @jobs.sum(&:length)

    unless scheduled_tasks.is_a?(Array) && scheduled_tasks.length == expected_task_count
      return { valid: false, errors: ["Scheduled task count mismatch"], calculated_makespan: nil }
    end

    tasks_by_key = {}
    machine_tasks = Hash.new { |hash, key| hash[key] = [] }

    scheduled_tasks.each do |task|
      unless valid_task_hash?(task)
        errors << "Scheduled task must include job_id, task_id, machine_id, duration, start_time, and end_time"
        next
      end

      key = [task.fetch(:job_id, task["job_id"]), task.fetch(:task_id, task["task_id"])]
      tasks_by_key[key] = normalized_task(task)
      machine_tasks[tasks_by_key.fetch(key).fetch(:machine_id)] << tasks_by_key.fetch(key)
    end

    @jobs.each_with_index do |job, job_id|
      job.each_with_index do |(machine_id, duration), task_id|
        task = tasks_by_key[[job_id, task_id]]
        if task.nil?
          errors << "Missing scheduled task for job #{job_id} task #{task_id}"
          next
        end

        errors << "Machine mismatch for job #{job_id} task #{task_id}" unless task.fetch(:machine_id) == machine_id
        errors << "Duration mismatch for job #{job_id} task #{task_id}" unless task.fetch(:duration) == duration
        errors << "Negative start time for job #{job_id} task #{task_id}" if task.fetch(:start_time) < -TOLERANCE
        unless (task.fetch(:end_time) - (task.fetch(:start_time) + duration)).abs <= TOLERANCE
          errors << "End time mismatch for job #{job_id} task #{task_id}"
        end
      end
    end

    @jobs.each_with_index do |job, job_id|
      job.each_index.each_cons(2) do |prev_task_id, task_id|
        previous = tasks_by_key[[job_id, prev_task_id]]
        current = tasks_by_key[[job_id, task_id]]
        next if previous.nil? || current.nil?

        if current.fetch(:start_time) + TOLERANCE < previous.fetch(:end_time)
          errors << "Precedence violated for job #{job_id} task #{task_id}"
        end
      end
    end

    machine_tasks.each_value do |tasks|
      tasks.sort_by { |task| [task.fetch(:start_time), task.fetch(:end_time)] }.each_cons(2) do |first, second|
        if second.fetch(:start_time) + TOLERANCE < first.fetch(:end_time)
          errors << "Machine overlap on machine #{first.fetch(:machine_id)}"
        end
      end
    end

    calculated_makespan = tasks_by_key.values.map { |task| task.fetch(:end_time) }.max || 0
    if (calculated_makespan - reported_makespan).abs > TOLERANCE
      errors << "Makespan mismatch: reported=#{reported_makespan}, calculated=#{calculated_makespan}"
    end

    {
      valid: errors.empty?,
      errors: errors,
      calculated_makespan: calculated_makespan
    }
  end

  private

  def valid_task_hash?(task)
    task.is_a?(Hash) &&
      task.key?(:job_id) || task.key?("job_id")
  end

  def normalized_task(task)
    {
      job_id: task.fetch(:job_id, task["job_id"]),
      task_id: task.fetch(:task_id, task["task_id"]),
      machine_id: task.fetch(:machine_id, task["machine_id"]),
      duration: task.fetch(:duration, task["duration"]),
      start_time: task.fetch(:start_time, task["start_time"]),
      end_time: task.fetch(:end_time, task["end_time"])
    }
  end
end
