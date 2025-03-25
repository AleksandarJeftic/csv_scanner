require "csv"
require "debug"

class FileReader
  def read
    CSV.foreach("files/change_entries_migrations.csv", headers: false) do |row|
      if invalid_row?(row)
        write_to_results(row)
      end
    end
  end

  def invalid_row?(row)
    result_message = row[4]

    return true if result_message.include?("No applicable migrator found") ||
      result_message.include?("Multiple applicable migrators found") ||
      result_message.include?("Error:")
    false
  end

  def write_to_results(row)
    CSV.open("output/results.csv", "a") do |csv|
      csv << row
    end
  end
end

FileReader.new.read
