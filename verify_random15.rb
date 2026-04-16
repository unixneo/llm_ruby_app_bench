#!/usr/bin/env ruby
# Verify TSP tour calculations for random_15

# Haversine distance calculation
def haversine(lat1, lon1, lat2, lon2)
  r = 6371.0 # Earth radius in km
  lat1_rad = lat1 * Math::PI / 180
  lat2_rad = lat2 * Math::PI / 180
  delta_lat = (lat2 - lat1) * Math::PI / 180
  delta_lon = (lon2 - lon1) * Math::PI / 180
  
  a = Math.sin(delta_lat/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(delta_lon/2)**2
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  r * c * 1000 # Convert to meters (km * 1000)
end

def calculate_tour_length(tour, distance_matrix)
  total = 0.0
  tour.each_cons(2) do |from, to|
    total += distance_matrix[from][to]
  end
  total
end

# For random_15, we need the distance matrix
# Let me just verify the calculation matches what's in the database

puts "For a proper verification, we need to:"
puts "1. Get the actual distance matrix for random_15 from the app"
puts "2. Calculate Held-Karp tour length: [0, 9, 7, 4, 13, 2, 8, 5, 10, 1, 12, 3, 14, 6, 11, 0]"
puts "3. Calculate OR-Tools tour length: [0, 6, 3, 14, 1, 12, 10, 5, 8, 13, 2, 7, 4, 9, 11, 0]"
puts "4. Compare results"
