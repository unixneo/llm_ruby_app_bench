class TspProblem
  attr_reader :distance_matrix, :name

  def initialize(distance_matrix:, name: nil)
    @distance_matrix = validate_distance_matrix(distance_matrix)
    @name = name
  end

  def self.euclidean(cities, name: nil)
    matrix = cities.map do |city_a|
      cities.map do |city_b|
        Math.sqrt((city_a.fetch(:x) - city_b.fetch(:x))**2 + (city_a.fetch(:y) - city_b.fetch(:y))**2)
      end
    end

    new(distance_matrix: matrix, name: name)
  end

  def self.haversine(cities, name: nil)
    matrix = cities.map do |city_a|
      cities.map do |city_b|
        haversine_distance(
          city_a.fetch(:latitude),
          city_a.fetch(:longitude),
          city_b.fetch(:latitude),
          city_b.fetch(:longitude)
        )
      end
    end

    new(distance_matrix: matrix, name: name)
  end

  def self.haversine_distance(from_latitude, from_longitude, to_latitude, to_longitude)
    earth_radius_km = 6371.0
    latitude_delta = degrees_to_radians(to_latitude - from_latitude)
    longitude_delta = degrees_to_radians(to_longitude - from_longitude)
    from_latitude_radians = degrees_to_radians(from_latitude)
    to_latitude_radians = degrees_to_radians(to_latitude)

    a = (Math.sin(latitude_delta / 2)**2) +
        (Math.cos(from_latitude_radians) * Math.cos(to_latitude_radians) * Math.sin(longitude_delta / 2)**2)

    earth_radius_km * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end

  def self.degrees_to_radians(degrees)
    degrees * Math::PI / 180.0
  end

  def city_count
    distance_matrix.length
  end

  def distance(from_index, to_index)
    distance_matrix.fetch(from_index).fetch(to_index)
  end

  private

  def validate_distance_matrix(matrix)
    raise ArgumentError, "distance matrix must be an array" unless matrix.is_a?(Array)
    raise ArgumentError, "distance matrix must not be empty" if matrix.empty?

    size = matrix.length
    matrix.map do |row|
      raise ArgumentError, "distance matrix must be square" unless row.is_a?(Array) && row.length == size

      row.map do |value|
        raise ArgumentError, "distance values must be numeric" unless value.is_a?(Numeric)

        value.to_f
      end
    end
  end
end
