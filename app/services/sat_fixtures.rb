class SatFixtures
  class << self
    def all
      [
        sat_trivial_sat_2,
        sat_trivial_unsat_2,
        sat_3sat_small_sat,
        sat_3sat_unsat,
        sat_3sat_medium_sat
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown SAT fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        SatProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.num_vars = fixture.fetch(:num_vars)
          problem.clauses = fixture.fetch(:clauses)
          problem.satisfiable = fixture.fetch(:satisfiable)
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def sat_trivial_sat_2
      {
        name: "sat_trivial_sat_2",
        num_vars: 2,
        clauses: [[1, 2], [-1, 2], [1, -2]],
        satisfiable: true,
        description: "Simple 2-variable SAT - manually verifiable"
      }
    end

    def sat_trivial_unsat_2
      {
        name: "sat_trivial_unsat_2",
        num_vars: 1,
        clauses: [[1], [-1]],
        satisfiable: false,
        description: "Trivially UNSAT - variable must be both true and false"
      }
    end

    def sat_3sat_small_sat
      {
        name: "sat_3sat_small_sat",
        num_vars: 4,
        clauses: [[1, 2, 3], [-1, 2, 4], [1, -2, -3], [-1, -2, 4], [2, 3, -4]],
        satisfiable: true,
        description: "Small 3-SAT instance with 4 variables and 5 clauses"
      }
    end

    def sat_3sat_unsat
      {
        name: "sat_3sat_unsat",
        num_vars: 3,
        clauses: [
          [1, 2, 3], [1, 2, -3], [1, -2, 3], [1, -2, -3],
          [-1, 2, 3], [-1, 2, -3], [-1, -2, 3], [-1, -2, -3]
        ],
        satisfiable: false,
        description: "All 8 truth-table clauses for 3 variables - UNSAT"
      }
    end

    def sat_3sat_medium_sat
      {
        name: "sat_3sat_medium_sat",
        num_vars: 6,
        clauses: [
          [1, 2, 3], [-1, 4, 5], [2, -3, 6], [-2, 3, -4],
          [1, -5, 6], [-1, -2, -6], [3, 4, -5], [-3, -4, 5]
        ],
        satisfiable: true,
        description: "Medium 3-SAT with 6 variables and 8 clauses"
      }
    end
  end
end
