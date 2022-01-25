# frozen_string_literal: true

# responsible for interactions with database
module Database
  attr_accessor :db
  TABLE_NAME = 'birthdays'
  require 'sqlite3'
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
    module_function(
      :database
    )
  end

  def setup
    # Initializing database file
    self.db = SQLite3::Database.open './lib/development.db'

    # Try to get custom table, if table not exists - create this one
    Create.database unless get_table(TABLE_NAME)
  end

  # save valid data as row to database
  def save(data)
    db.execute(
      "INSERT INTO #{TABLE_NAME} (user_id, name, date)
      VALUES (?, ?, ?)", [data[:user_id], data[:name], data[:date]]
    )
  end

  def select
    data = []
    db.execute("select * from #{TABLE_NAME}") do |row|
      data << row
    end
    data
  end

  # Get all from the selected table
  def get_table(table_name)
    db.execute <<-SQL
    Select * from #{table_name}
    SQL
  rescue SQLite3::SQLException
    false
  end

  module_function(
    :get_table,
    :select,
    :setup,
    :save,
    :db,
    :db=
  )
end
