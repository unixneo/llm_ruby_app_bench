class JobShopProblem < ApplicationRecord
  serialize :jobs, coder: JSON

  validates :name, presence: true, uniqueness: true
  validate :valid_jobs_structure

  def machine_count
    jobs.flatten(1).map(&:first).max.to_i + 1
  end

  def job_count
    jobs.length
  end

  def task_count
    jobs.sum(&:length)
  end

  private

  def valid_jobs_structure
    unless jobs.is_a?(Array) && jobs.any? && jobs.all? { |job| valid_job?(job) }
      errors.add(:jobs, "must be an array of jobs, each containing [machine_id, duration] integer pairs")
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
end
