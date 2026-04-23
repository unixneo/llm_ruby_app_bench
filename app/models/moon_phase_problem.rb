class MoonPhaseProblem < ApplicationRecord
  serialize :expected_events, coder: JSON

  validates :name, presence: true, uniqueness: true
  validates :fixture_type, presence: true, inclusion: { in: %w[daily events] }
  validate :daily_fixture_fields
  validate :event_fixture_fields

  def daily_fixture?
    fixture_type == "daily"
  end

  def event_fixture?
    fixture_type == "events"
  end

  private

  def daily_fixture_fields
    return unless daily_fixture?

    errors.add(:observation_date, "must be present for daily fixtures") if observation_date.blank?
    errors.add(:expected_illuminated_fraction, "must be present for daily fixtures") if expected_illuminated_fraction.blank?
    errors.add(:expected_phase_fraction, "must be present for daily fixtures") if expected_phase_fraction.blank?
    errors.add(:expected_phase_name, "must be present for daily fixtures") if expected_phase_name.blank?
  end

  def event_fixture_fields
    return unless event_fixture?

    errors.add(:year, "must be present for event fixtures") if year.blank?
    errors.add(:month, "must be present for event fixtures") if month.blank?
    errors.add(:expected_events, "must be present for event fixtures") if expected_events.blank?
  end
end
