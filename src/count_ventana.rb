require "csv"
require "debug"

class CountVentana
  def read
    counter = 0
    CSV.foreach("files/change_entries_migrations.csv", headers: false) do |row|
      if row[0] == "ventana"
        counter += 1
      end
    end
    puts counter
  end
end
  

CountVentana.new.read
