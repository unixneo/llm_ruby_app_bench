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
    candidate_result_data.fetch("tour")
  end

  def reference_tour
    reference_result_data.fetch("tour")
  end

  def candidate_tour_display
    tour_display(candidate_tour)
  end

  def reference_tour_display
    tour_display(reference_tour)
  end

  def fixture
    @fixture ||= TspFixtures.find(fixture_name)
  end

  def city_names
    fixture.fetch(:city_names, nil)
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

  def tour_display(tour)
    return "Unavailable" unless tour
    return tour.inspect unless city_names

    tour.map { |city_index| city_names.fetch(city_index) }.join(" -> ")
  end
end
