module TspFixtures
  module_function

  def all
    [square_4, hexagon_6, octagon_8, random_10, random_15, random_20, world_cities_13]
  end

  def find(name)
    all.find { |fixture| fixture.fetch(:name) == name } || raise(ArgumentError, "unknown fixture: #{name}")
  end

  def square_4
    {
      name: "square_4",
      description: "Four cities at the corners of a unit square; optimal tour is the perimeter.",
      cities: [
        { x: 0.0, y: 0.0 },
        { x: 1.0, y: 0.0 },
        { x: 1.0, y: 1.0 },
        { x: 0.0, y: 1.0 }
      ],
      optimal_tour: [0, 1, 2, 3, 0],
      optimal_length: 4.0
    }
  end

  def hexagon_6
    cities = regular_polygon(6)

    {
      name: "hexagon_6",
      description: "Six cities on a unit circle; optimal tour follows the regular hexagon perimeter.",
      cities: cities,
      optimal_tour: [0, 1, 2, 3, 4, 5, 0],
      optimal_length: 6.0
    }
  end

  def octagon_8
    cities = regular_polygon(8)

    {
      name: "octagon_8",
      description: "Eight cities on a unit circle; optimal tour follows the regular octagon perimeter.",
      cities: cities,
      optimal_tour: [0, 1, 2, 3, 4, 5, 6, 7, 0],
      optimal_length: 8 * Math.sqrt(2 - Math.sqrt(2))
    }
  end

  def random_10
    asymmetric_fixture("random_10", 10)
  end

  def random_15
    asymmetric_fixture("random_15", 15)
  end

  def random_20
    asymmetric_fixture("random_20", 20)
  end

  def world_cities_13
    cities = [
      { name: "Tokyo", latitude: 35.6762, longitude: 139.6503 },
      { name: "Delhi", latitude: 28.7041, longitude: 77.1025 },
      { name: "Shanghai", latitude: 31.2304, longitude: 121.4737 },
      { name: "Sao Paulo", latitude: -23.5505, longitude: -46.6333 },
      { name: "Mexico City", latitude: 19.4326, longitude: -99.1332 },
      { name: "Cairo", latitude: 30.0444, longitude: 31.2357 },
      { name: "Mumbai", latitude: 19.0760, longitude: 72.8777 },
      { name: "Beijing", latitude: 39.9042, longitude: 116.4074 },
      { name: "Dhaka", latitude: 23.8103, longitude: 90.4125 },
      { name: "Osaka", latitude: 34.6937, longitude: 135.5023 },
      { name: "New York City", latitude: 40.7128, longitude: -74.0060 },
      { name: "Karachi", latitude: 24.8607, longitude: 67.0011 },
      { name: "Buenos Aires", latitude: -34.6037, longitude: -58.3816 }
    ]

    {
      name: "world_cities_13",
      description: "Thirteen major world cities using haversine great-circle distances in kilometers.",
      cities: cities,
      city_names: cities.map { |city| city.fetch(:name) },
      distance_type: "haversine"
    }
  end

  def problem_for(fixture)
    if fixture.key?(:distance_matrix)
      TspProblem.new(distance_matrix: fixture.fetch(:distance_matrix), name: fixture.fetch(:name))
    elsif fixture.fetch(:distance_type, nil) == "haversine"
      TspProblem.haversine(fixture.fetch(:cities), name: fixture.fetch(:name))
    else
      TspProblem.euclidean(fixture.fetch(:cities), name: fixture.fetch(:name))
    end
  end

  def regular_polygon(city_count)
    city_count.times.map do |index|
      angle = (2 * Math::PI * index) / city_count
      {
        x: Math.cos(angle),
        y: Math.sin(angle)
      }
    end
  end

  def asymmetric_fixture(name, city_count)
    cities = deterministic_cities(city_count)

    {
      name: name,
      description: "#{city_count} deterministic asymmetric directed distances for solver scalability testing.",
      cities: cities,
      distance_matrix: asymmetric_distance_matrix(cities)
    }
  end

  def deterministic_cities(city_count)
    city_count.times.map do |index|
      {
        x: ((index * 37) % 101) / 10.0,
        y: ((index * 53 + 17) % 97) / 10.0
      }
    end
  end

  def asymmetric_distance_matrix(cities)
    cities.each_with_index.map do |from_city, from_index|
      cities.each_with_index.map do |to_city, to_index|
        next 0.0 if from_index == to_index

        euclidean_distance(from_city, to_city) + directional_penalty(from_index, to_index)
      end
    end
  end

  def euclidean_distance(from_city, to_city)
    Math.sqrt((from_city.fetch(:x) - to_city.fetch(:x))**2 + (from_city.fetch(:y) - to_city.fetch(:y))**2)
  end

  def directional_penalty(from_index, to_index)
    modular_penalty = ((from_index * 11 + to_index * 7) % 13) / 10.0
    direction_penalty = to_index > from_index ? 0.15 : 0.55

    modular_penalty + direction_penalty
  end
end
