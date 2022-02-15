# frozen_string_literal: true

# responsible for interactions with database
module State
  attr_accessor :db

  TABLE_NAME = 'state'

  # creates Database
  module Create
    def state_db
      State.db.execute(
        "create table #{TABLE_NAME} (
          user_id integer primary key,
          name varchar(50),
          date varchar(50),
          state varchar(50),
          record_id integer
        )"
      )
      true
    rescue SQLite3::SQLException
      false
    end
    module_function(
      :state_db
    )
  end

  def setup
    # Initializing database file
    self.db = SQLite3::Database.open './lib/development.db'

    # Try to get custom table, if table not exists - create this one
    Create.state_db unless get_table(TABLE_NAME)
  end

  def replace(data)
    db.execute(
      "REPLACE INTO #{TABLE_NAME} (user_id, name, date, state, record_id)
      VALUES (?, ?, ?, ?, ?)", [data[:user_id], data[:name], data[:date], data[:state], data[:record_id]]
    )
  end

  # save valid data as row to database
  def save(data)
    db.execute(
      "INSERT INTO #{TABLE_NAME} (user_id, name, date, state, record_id)
      VALUES (?, ?, ?, ?, ?)", [data[:user_id], data[:name], data[:date], data[:state], data[:record_id]]
    )
  end

  def check_state(user_id)
    db.execute("select * from #{TABLE_NAME} where user_id = #{user_id}") do |row|
      return { 'user_id': row[0],
               'name': row[1],
               'date': row[2],
               'state': row[3],
               'record_id': row[4] }
    end
  end

  # Get all from the selected table
  def get_table(table_name)
    db.execute(
      "Select * from #{table_name}"
    )
  rescue SQLite3::SQLException
    false
  end

  module_function(
    :get_table,
    :check_state,
    :replace,
    :setup,
    :save,
    :db,
    :db=
  )
end
