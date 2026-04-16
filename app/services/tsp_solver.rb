class TspSolver
  MAX_CITIES = 8
  HELD_KARP_MAX_CITIES = 20

  Result = Data.define(:tour, :length, :source, :objective_value, :scale) do
    def to_h
      {
        tour: tour,
        length: length,
        source: source,
        objective_value: objective_value,
        scale: scale
      }
    end
  end

  def initialize(algorithm: :auto)
    @algorithm = algorithm
  end

  def solve(problem)
    case @algorithm
    when :auto
      solve_auto(problem)
    when :brute_force
      solve_brute_force(problem)
    when :nearest_neighbor
      solve_nearest_neighbor(problem)
    when :held_karp
      solve_held_karp(problem)
    else
      raise ArgumentError, "unknown TSP algorithm: #{@algorithm}"
    end
  end

  private

  def solve_auto(problem)
    city_count = problem.city_count

    if city_count <= MAX_CITIES
      solve_brute_force(problem)
    else
      solve_held_karp(problem)
    end
  end

  def solve_brute_force(problem)
    city_count = problem.city_count
    raise ArgumentError, "brute-force solver supports n<=#{MAX_CITIES}" if city_count > MAX_CITIES

    return build_result(tour: [0, 0], length: 0.0, source: "brute-force") if city_count == 1

    best_tour = nil
    best_length = Float::INFINITY
    remaining = (1...city_count).to_a

    remaining.permutation.each do |permutation|
      next if reversed_duplicate?(permutation)

      tour = [0] + permutation + [0]
      length = tour.each_cons(2).sum { |from_index, to_index| problem.distance(from_index, to_index) }

      if length < best_length
        best_tour = tour
        best_length = length
      end
    end

    build_result(tour: best_tour, length: best_length, source: "brute-force")
  end

  def solve_nearest_neighbor(problem)
    city_count = problem.city_count
    unvisited = (1...city_count).to_a
    tour = [0]

    until unvisited.empty?
      current_city = tour.last
      next_city = unvisited.min_by { |city| problem.distance(current_city, city) }

      tour << next_city
      unvisited.delete(next_city)
    end

    tour << 0
    build_result(tour: tour, length: tour_length(problem, tour), source: "nearest-neighbor")
  end

  def solve_held_karp(problem)
    city_count = problem.city_count
    raise ArgumentError, "held-karp solver supports n<=#{HELD_KARP_MAX_CITIES}" if city_count > HELD_KARP_MAX_CITIES

    return build_result(tour: [0, 0], length: 0.0, source: "held-karp") if city_count == 1

    non_start_count = city_count - 1
    total_masks = 1 << non_start_count
    width = non_start_count
    infinity = Float::INFINITY
    costs = Array.new(total_masks * width, infinity)
    parents = Array.new(total_masks * width)

    width.times do |endpoint_offset|
      city = endpoint_offset + 1
      mask = 1 << endpoint_offset
      costs[table_index(mask, endpoint_offset, width)] = problem.distance(0, city)
    end

    total_masks.times do |mask|
      width.times do |endpoint_offset|
        endpoint_bit = 1 << endpoint_offset
        next if (mask & endpoint_bit).zero?

        current_index = table_index(mask, endpoint_offset, width)
        current_cost = costs[current_index]
        next if current_cost.infinite?

        endpoint_city = endpoint_offset + 1
        remaining = ((total_masks - 1) ^ mask)

        while remaining.positive?
          next_bit = remaining & -remaining
          next_offset = bit_offset(next_bit)
          next_mask = mask | next_bit
          next_index = table_index(next_mask, next_offset, width)
          next_city = next_offset + 1
          candidate_cost = current_cost + problem.distance(endpoint_city, next_city)

          if candidate_cost < costs[next_index]
            costs[next_index] = candidate_cost
            parents[next_index] = endpoint_offset
          end

          remaining &= remaining - 1
        end
      end
    end

    full_mask = total_masks - 1
    best_endpoint_offset = nil
    best_length = infinity

    width.times do |endpoint_offset|
      endpoint_city = endpoint_offset + 1
      candidate_length = costs[table_index(full_mask, endpoint_offset, width)] + problem.distance(endpoint_city, 0)

      if candidate_length < best_length
        best_length = candidate_length
        best_endpoint_offset = endpoint_offset
      end
    end

    build_result(
      tour: reconstruct_held_karp_tour(parents, full_mask, best_endpoint_offset, width),
      length: best_length,
      source: "held-karp"
    )
  end

  def build_result(tour:, length:, source:)
    Result.new(
      tour: tour,
      length: length,
      source: source,
      objective_value: length,
      scale: 1
    )
  end

  def tour_length(problem, tour)
    tour.each_cons(2).sum { |from_index, to_index| problem.distance(from_index, to_index) }
  end

  def reconstruct_held_karp_tour(parents, full_mask, endpoint_offset, width)
    mask = full_mask
    path = []

    while endpoint_offset
      path << endpoint_offset + 1
      parent_offset = parents[table_index(mask, endpoint_offset, width)]
      mask &= ~(1 << endpoint_offset)
      endpoint_offset = parent_offset
    end

    [0] + path.reverse + [0]
  end

  def table_index(mask, endpoint_offset, width)
    (mask * width) + endpoint_offset
  end

  def bit_offset(bit)
    bit.bit_length - 1
  end

  def reversed_duplicate?(permutation)
    permutation.length > 1 && permutation.first > permutation.last
  end
end
