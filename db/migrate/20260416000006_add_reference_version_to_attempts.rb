class AddReferenceVersionToAttempts < ActiveRecord::Migration[7.2]
  LEGACY_REFERENCE_VERSION = "or-tools-path-cheapest-arc-v1"

  def up
    add_column :attempts, :reference_version, :string

    backfill_reference_versions

    change_column_null :attempts, :reference_version, false
    remove_index :attempts, name: "index_attempts_on_prompt_fixture_algorithm"
    add_index :attempts, [:prompt_id, :fixture_name, :algorithm_version, :reference_version],
              unique: true,
              name: "index_attempts_on_prompt_fixture_algorithm_reference"
    add_index :attempts, :reference_version
  end

  def down
    remove_index :attempts, name: "index_attempts_on_prompt_fixture_algorithm_reference"
    remove_index :attempts, :reference_version
    add_index :attempts, [:prompt_id, :fixture_name, :algorithm_version],
              unique: true,
              name: "index_attempts_on_prompt_fixture_algorithm"
    remove_column :attempts, :reference_version
  end

  private

  def backfill_reference_versions
    select_all("SELECT id, reference_result FROM attempts").each do |row|
      version = reference_version_for(row.fetch("reference_result"))

      execute <<~SQL.squish
        UPDATE attempts
        SET reference_version = #{quote(version)}
        WHERE id = #{row.fetch("id")}
      SQL
    end
  end

  def reference_version_for(reference_result)
    JSON.parse(reference_result).fetch("reference_version", LEGACY_REFERENCE_VERSION)
  rescue JSON::ParserError
    LEGACY_REFERENCE_VERSION
  end
end
