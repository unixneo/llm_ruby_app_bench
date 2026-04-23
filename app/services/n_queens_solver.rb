class NQueensSolver
  SOURCE = "backtracking"

  Result = Data.define(:n, :count, :solutions, :method, :duration, :source) do
    def to_h
      {
        n: n,
        count: count,
        solutions: solutions,
        method: method,
        duration: duration,
        source: source
      }
    end
  end

  def initialize(n)
    @n = n
  end

  def solve
    start = Time.now
    collect_solutions = @n <= 10

    columns = Array.new(@n, false)
    main_diag = Array.new((2 * @n) - 1, false)
    anti_diag = Array.new((2 * @n) - 1, false)
    solutions = []
    count = place_queen(
      0,
      [],
      columns,
      main_diag,
      anti_diag,
      solutions,
      collect_solutions
    )

    Result.new(
      n: @n,
      count: count,
      solutions: collect_solutions ? solutions : nil,
      method: :backtracking,
      duration: Time.now - start,
      source: SOURCE
    )
  end

  private

  def place_queen(row, queens, columns, main_diag, anti_diag, solutions, collect_solutions)
    if row == @n
      solutions << queens.dup if collect_solutions
      return 1
    end

    row_count = 0

    @n.times do |col|
      main_index = row - col + @n - 1
      anti_index = row + col
      next if columns[col] || main_diag[main_index] || anti_diag[anti_index]

      columns[col] = true
      main_diag[main_index] = true
      anti_diag[anti_index] = true
      queens << col

      row_count += place_queen(
        row + 1,
        queens,
        columns,
        main_diag,
        anti_diag,
        solutions,
        collect_solutions
      )

      queens.pop
      columns[col] = false
      main_diag[main_index] = false
      anti_diag[anti_index] = false
    end

    row_count
  end
end

