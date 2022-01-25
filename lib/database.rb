# frozen_string_literal: true

# responsible for interactions with database
class Database
  attr_accessor :db

  # creates Database
  module Create
    def database
      Database.db.execute <<~SQL
        create table birthdays(
          user_id integer,
          name varchar(50),
          date varchar(50)
        );
      SQL
      true
    rescue SQLite3::SQLException
      false
    end
  end

  def setup
    # Initializing database file
    self.db = SQLite3::Database.open 'development.db'

    # Try to get custom table, if table not exists - create this one
    Create.database unless get_table('birthdays')
  end

  # save valid data as row to database
  def save(data)
    db.execute(
      "INSERT INTO birthdays (user_id, name, date)
      VALUES (?, ?, ?)", [data[:user_id], data[:name], data[:date]]
    )
  end

  private

  # Get all from the selected table
  def get_table(table_name)
    db.execute <<-SQL
    Select * from #{table_name}
    SQL
  rescue SQLite3::SQLException
    false
  end

  module_function(
    :db,
    :db=
  )
end
