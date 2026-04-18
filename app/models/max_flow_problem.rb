class MaxFlowProblem < ApplicationRecord
  serialize :edges, coder: JSON

  validates :name, presence: true, uniqueness: true
  validates :nodes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :source, :sink, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :valid_edges_structure
  validate :source_and_sink_in_range
  validate :edge_nodes_in_range

  private

  def valid_edges_structure
    unless edges.is_a?(Array) &&
        edges.all? { |edge| edge.is_a?(Array) && edge.length == 3 && edge.all? { |value| value.is_a?(Integer) } && edge.fetch(2) >= 0 }
      errors.add(:edges, "must be array of [from, to, capacity] integer triples with nonnegative capacities")
    end
  end

  def source_and_sink_in_range
    return if nodes.blank? || source.blank? || sink.blank?

    errors.add(:source, "must be in range [0, #{nodes - 1}]") unless source.between?(0, nodes - 1)
    errors.add(:sink, "must be in range [0, #{nodes - 1}]") unless sink.between?(0, nodes - 1)
    errors.add(:sink, "cannot equal source") if source == sink
  end

  def edge_nodes_in_range
    return unless edges.is_a?(Array) && nodes.present?

    edges.each do |from, to, _capacity|
      next unless from.is_a?(Integer) && to.is_a?(Integer)

      errors.add(:edges, "edge node #{from} must be in range [0, #{nodes - 1}]") unless from.between?(0, nodes - 1)
      errors.add(:edges, "edge node #{to} must be in range [0, #{nodes - 1}]") unless to.between?(0, nodes - 1)
    end
  end
end
