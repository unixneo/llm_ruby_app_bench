class Attempt < ApplicationRecord
  STATUSES = {
    "exact_match" => {
      label: "Exact match",
      badge_class: "badge-pass"
    },
    "different_optimal" => {
      label: "Different route",
      badge_class: "badge-warning"
    },
    "length_mismatch" => {
      label: "Error",
      badge_class: "badge-fail"
    },
    "candidate_failed" => {
      label: "Candidate failed",
      badge_class: "badge-fail"
    },
    "feasible" => {
      label: "Feasible",
      badge_class: "badge-pass"
    },
    "infeasible" => {
      label: "Infeasible",
      badge_class: "badge-fail"
    },
    "reference_failed" => {
      label: "Reference failed",
      badge_class: "badge-fail"
    }
  }.freeze

  belongs_to :challenge
  has_one :interpretation, dependent: :destroy

  validates :prompt_id,
            :fixture_name,
            :algorithm_version,
            :reference_version,
            :candidate_result,
            :reference_result,
            :status,
            presence: true

  def candidate_result_data
    JSON.parse(candidate_result)
  end

  def reference_result_data
    JSON.parse(reference_result)
  end

  def status_label
    STATUSES.fetch(status, { label: status.humanize }).fetch(:label)
  end

  def status_badge_class
    STATUSES.fetch(status, { badge_class: "badge-other" }).fetch(:badge_class)
  end

  def candidate_tour
    candidate_result_data.fetch("tour", nil)
  end

  def reference_tour
    reference_result_data.fetch("tour", nil)
  end

  def candidate_tour_display
    route_display(candidate_result_data)
  end

  def reference_tour_display
    route_display(reference_result_data)
  end

  def fixture
    @fixture ||= if challenge.name == "Traveling Salesman Problem"
      TspFixtures.find(fixture_name)
    elsif challenge.name == "Vehicle Routing Problem"
      VrpFixtures.find(fixture_name)
    elsif challenge.name == "Assignment Problem"
      AssignmentProblem.find_by(name: fixture_name)
    elsif challenge.name == "Job Shop Scheduling Problem"
      JobShopProblem.find_by(name: fixture_name)
    elsif challenge.name == "Moon Phase Calculations"
      MoonPhaseProblem.find_by(name: fixture_name)
    elsif challenge.name == "N-Queens Problem"
      NQueensProblem.find_by(name: fixture_name)
    elsif challenge.name == "Minimum Cost Flow Problem"
      MinCostFlowProblem.find_by(name: fixture_name)
    elsif challenge.name == "Max Flow Problem"
      MaxFlowProblem.find_by(name: fixture_name)
    end
  end

  def city_names
    fixture&.fetch(:city_names, nil)
  end

  def distance_difference_label
    case challenge.name
    when "Vehicle Routing Problem"
      "Distance Difference"
    when "Assignment Problem", "Minimum Cost Flow Problem"
      "Cost Difference"
    when "Job Shop Scheduling Problem"
      "Makespan Difference"
    when "Moon Phase Calculations"
      moon_phase_difference_label
    when "N-Queens Problem"
      "Count Difference"
    when "Max Flow Problem"
      "Flow Difference"
    else
      "Length Difference"
    end
  end

  def candidate_route_label
    case challenge.name
    when "Vehicle Routing Problem"
      "Candidate Routes"
    when "Assignment Problem"
      "Candidate Assignment"
    when "Job Shop Scheduling Problem"
      "Candidate Schedule"
    when "Moon Phase Calculations"
      "Candidate Result"
    when "N-Queens Problem"
      "Candidate Result"
    when "Minimum Cost Flow Problem"
      "Candidate Flow"
    when "Max Flow Problem"
      "Candidate Flow"
    else
      "Candidate Tour"
    end
  end

  def reference_route_label
    case challenge.name
    when "Vehicle Routing Problem"
      "Reference Routes"
    when "Assignment Problem"
      "Reference Assignment"
    when "Job Shop Scheduling Problem"
      "Reference Schedule"
    when "Moon Phase Calculations"
      "Reference Result"
    when "N-Queens Problem"
      "Reference Result"
    when "Minimum Cost Flow Problem"
      "Reference Flow"
    when "Max Flow Problem"
      "Reference Flow"
    else
      "Gem Tour"
    end
  end

  def source_label
    challenge.name == "Vehicle Routing Problem" ? "Reference" : "Reference"
  end

  def route_path_name
    case challenge.name
    when "Vehicle Routing Problem"
      :vrp
    when "Assignment Problem"
      :assignment
    when "Job Shop Scheduling Problem"
      :job_shop
    when "Moon Phase Calculations"
      :moon_phase
    when "N-Queens Problem"
      :n_queens
    when "Minimum Cost Flow Problem"
      :min_cost_flow
    when "Max Flow Problem"
      :max_flow
    else
      :tsp
    end
  end

  def self.algorithm_version_for_source(source)
    case source
    when "brute-force"
      "brute-force-v1"
    when "nearest-neighbor"
      "nearest-neighbor-v1"
    else
      "#{source}-v1"
    end
  end

  private

  def route_display(result_data)
    if result_data.key?("flow_edges")
      return result_data.fetch("flow_edges").map do |from, to, flow|
        "#{from} -> #{to}: #{flow}"
      end.join(" | ")
    end

    if result_data.key?("major_events") && result_data.fetch("major_events").any?
      return result_data.fetch("major_events").map do |event|
        "#{event.fetch("phase")}: #{event.fetch("time")}"
      end.join(" | ")
    end

    if result_data.key?("count")
      return [
        "n=#{result_data.fetch("n", "n/a")}",
        "count=#{result_data.fetch("count", "n/a")}",
        "method=#{result_data.fetch("method", "n/a")}",
        "duration=#{result_data.fetch("duration", "n/a")}"
      ].join(" | ")
    end

    if result_data.key?("phase_name")
      return [
        "phase=#{result_data.fetch("phase_name")}",
        "fraction=#{result_data.fetch("phase_fraction", "n/a")}",
        "illum=#{result_data.fetch("illuminated_fraction", "n/a")}"
      ].join(" | ")
    end

    if result_data.key?("scheduled_tasks")
      return result_data.fetch("scheduled_tasks").map do |task|
        "J#{task.fetch("job_id")}T#{task.fetch("task_id")} M#{task.fetch("machine_id")} @ #{task.fetch("start_time")}-#{task.fetch("end_time")}"
      end.join(" | ")
    end

    if result_data.key?("assignment")
      return result_data.fetch("assignment").each_with_index.map do |task, worker|
        "Worker #{worker} -> Task #{task}"
      end.join(" | ")
    end

    if result_data.key?("routes")
      return result_data.fetch("routes").map.with_index do |route, index|
        "Vehicle #{index + 1}: #{node_sequence_display(route)}"
      end.join(" | ")
    end

    node_sequence_display(result_data.fetch("tour", nil))
  end

  def node_sequence_display(tour)
    return "Unavailable" unless tour
    return tour.inspect unless city_names

    tour.map { |city_index| city_names.fetch(city_index) }.join(" -> ")
  end

  def moon_phase_difference_label
    fixture_type = candidate_result_data["fixture_type"] || reference_result_data["fixture_type"] || fixture&.fixture_type

    if fixture_type == "events"
      "Max Event Offset (minutes)"
    else
      "Max Fraction Difference"
    end
  end
end
