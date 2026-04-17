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
    end
  end

  def city_names
    fixture&.fetch(:city_names, nil)
  end

  def distance_difference_label
    challenge.name == "Vehicle Routing Problem" ? "Distance Difference" : "Length Difference"
  end

  def candidate_route_label
    challenge.name == "Vehicle Routing Problem" ? "Candidate Routes" : "Candidate Tour"
  end

  def reference_route_label
    challenge.name == "Vehicle Routing Problem" ? "Reference Routes" : "Gem Tour"
  end

  def source_label
    challenge.name == "Vehicle Routing Problem" ? "Reference" : "Reference"
  end

  def route_path_name
    challenge.name == "Vehicle Routing Problem" ? :vrp : :tsp
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
end
