class VrpFixtures
  class << self
    def all
      [
        small_5,
        symmetric_8,
        asymmetric_10,
        tight_capacity_12,
        larger_20
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown VRP fixture: #{name}")
    end

    def problem_for(fixture)
      VrpProblem.new(
        num_vehicles: fixture.fetch(:num_vehicles),
        vehicle_capacity: fixture.fetch(:vehicle_capacity),
        demands: fixture.fetch(:demands),
        depot: fixture.fetch(:depot),
        distance_matrix: fixture.fetch(:distance_matrix)
      )
    end

    def small_5
      {
        name: "vrp_small_5",
        num_vehicles: 2,
        vehicle_capacity: 15,
        depot: 0,
        demands: [0, 7, 5, 8, 6, 1],
        distance_matrix: [
          [0, 10, 8, 15, 12, 9],
          [10, 0, 5, 12, 8, 7],
          [8, 5, 0, 9, 6, 4],
          [15, 12, 9, 0, 7, 11],
          [12, 8, 6, 7, 0, 5],
          [9, 7, 4, 11, 5, 0]
        ]
      }
    end

    def symmetric_8
      from_coordinates(
        name: "vrp_symmetric_8",
        num_vehicles: 2,
        vehicle_capacity: 18,
        depot: [0, 0],
        customers: [
          [2, 3, 4], [4, 4, 5], [6, 1, 3], [7, 5, 6],
          [-2, 4, 4], [-4, 2, 3], [-5, -1, 5], [3, -3, 4]
        ]
      )
    end

    def asymmetric_10
      asymmetric_from_coordinates(
        from_coordinates(
          name: "vrp_asymmetric_10",
          num_vehicles: 3,
        vehicle_capacity: 18,
          depot: [0, 0],
          customers: [
            [1, 4, 5], [3, 7, 4], [6, 5, 6], [8, 2, 3], [5, -2, 4],
            [2, -5, 5], [-2, -4, 6], [-5, -2, 3], [-6, 3, 4], [-3, 6, 5]
          ]
        )
      )
    end

    def tight_capacity_12
      from_coordinates(
        name: "vrp_tight_capacity_12",
        num_vehicles: 3,
        vehicle_capacity: 30,
        depot: [0, 0],
        customers: [
          [2, 6, 7], [5, 7, 6], [7, 4, 8], [8, -1, 5],
          [4, -5, 7], [1, -7, 6], [-3, -6, 8], [-7, -3, 5],
          [-8, 2, 6], [-5, 6, 7], [-1, 8, 5], [3, 2, 4]
        ]
      )
    end

    def larger_20
      asymmetric_from_coordinates(
        from_coordinates(
          name: "vrp_larger_20",
          num_vehicles: 5,
          vehicle_capacity: 24,
          depot: [0, 0],
          customers: [
            [2, 8, 5], [5, 9, 6], [8, 7, 4], [10, 3, 7], [9, -1, 5],
            [7, -5, 6], [4, -8, 4], [1, -9, 5], [-2, -8, 6], [-5, -7, 4],
            [-8, -4, 7], [-10, 0, 5], [-9, 4, 6], [-6, 8, 4], [-3, 9, 5],
            [0, 6, 7], [3, 4, 3], [6, 2, 5], [-4, 2, 6], [-1, -4, 4]
          ]
        )
      )
    end

    private

    def from_coordinates(name:, num_vehicles:, vehicle_capacity:, depot:, customers:)
      coordinates = [depot] + customers.map { |x, y, _demand| [x, y] }
      demands = [0] + customers.map { |_x, _y, demand| demand }
      matrix = coordinates.map do |from_x, from_y|
        coordinates.map do |to_x, to_y|
          Math.sqrt(((from_x - to_x)**2) + ((from_y - to_y)**2)).round(3)
        end
      end

      {
        name: name,
        num_vehicles: num_vehicles,
        vehicle_capacity: vehicle_capacity,
        depot: 0,
        demands: demands,
        distance_matrix: matrix,
        coordinates: coordinates
      }
    end

    def asymmetric_from_coordinates(fixture)
      matrix = fixture.fetch(:distance_matrix).each_with_index.map do |row, from_index|
        row.each_with_index.map do |distance, to_index|
          next distance if from_index == to_index

          (distance + ((from_index * 3 + to_index * 5) % 4) * 0.35).round(3)
        end
      end

      fixture.merge(distance_matrix: matrix)
    end
  end
end
