class AddAlgorithmVersionToAttempts < ActiveRecord::Migration[7.2]
  def up
    add_column :attempts, :algorithm_version, :string

    backfill_algorithm_versions

    change_column_null :attempts, :algorithm_version, false
    remove_index :attempts, name: "index_attempts_on_prompt_id_and_fixture_name"
    add_index :attempts, [:prompt_id, :fixture_name, :algorithm_version],
              unique: true,
              name: "index_attempts_on_prompt_fixture_algorithm"
    add_index :attempts, :algorithm_version
  end

  def down
    remove_index :attempts, name: "index_attempts_on_prompt_fixture_algorithm"
    remove_index :attempts, :algorithm_version
    add_index :attempts, [:prompt_id, :fixture_name],
              unique: true,
              name: "index_attempts_on_prompt_id_and_fixture_name"
    remove_column :attempts, :algorithm_version
  end

  private

  def backfill_algorithm_versions
    select_all("SELECT id, candidate_result FROM attempts").each do |row|
      source = candidate_source(row.fetch("candidate_result"))
      version = algorithm_version_for(source)

      execute <<~SQL.squish
        UPDATE attempts
        SET algorithm_version = #{quote(version)}
        WHERE id = #{row.fetch("id")}
      SQL
    end
  end

  def candidate_source(candidate_result)
    JSON.parse(candidate_result).fetch("source", "unknown")
  rescue JSON::ParserError
    "unknown"
  end

  def algorithm_version_for(source)
    case source
    when "brute-force"
      "brute-force-v1"
    when "nearest-neighbor"
      "nearest-neighbor-v1"
    else
      "unknown-v1"
    end
  end
end
