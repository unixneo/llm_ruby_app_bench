class VrpProblem
  attr_reader :num_vehicles, :vehicle_capacity, :demands, :depot, :distance_matrix

  def initialize(num_vehicles:, vehicle_capacity:, demands:, depot:, distance_matrix:)
    @num_vehicles = Integer(num_vehicles)
    @vehicle_capacity = Integer(vehicle_capacity)
    @demands = demands.map { |demand| Integer(demand) }
    @depot = Integer(depot)
    @distance_matrix = distance_matrix.map { |row| row.map { |distance| Float(distance) } }

    validate!
  end

  def location_count
    distance_matrix.length
  end

  def customer_indices
    (0...location_count).reject { |index| index == depot }
  end

  def distance(from_index, to_index)
    distance_matrix.fetch(from_index).fetch(to_index)
  end

  def route_load(route)
    route.uniq.sum { |index| index == depot ? 0 : demands.fetch(index) }
  end

  def route_distance(route)
    route.each_cons(2).sum { |from_index, to_index| distance(from_index, to_index) }
  end

  private

  def validate!
    raise ArgumentError, "num_vehicles must be positive" unless num_vehicles.positive?
    raise ArgumentError, "vehicle_capacity must be positive" unless vehicle_capacity.positive?
    raise ArgumentError, "distance matrix must not be empty" if distance_matrix.empty?
    raise ArgumentError, "depot index is out of range" unless depot.between?(0, location_count - 1)
    raise ArgumentError, "demands length must match distance matrix size" unless demands.length == location_count

    demands.each_with_index do |demand, index|
      if index == depot
        raise ArgumentError, "depot demand must be zero" unless demand.zero?
      elsif demand <= 0
        raise ArgumentError, "customer demands must be positive integers"
      elsif demand > vehicle_capacity
        raise ArgumentError, "customer demand exceeds vehicle capacity"
      end
    end

    distance_matrix.each do |row|
      raise ArgumentError, "distance matrix must be square" unless row.length == location_count
    end
  end
end
