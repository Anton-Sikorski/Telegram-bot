# frozen_string_literal: true

# responsible for interactions with users options
module Users
  attr_accessor :db

  TABLE_NAME = 'users'

  # creates User database
  module Create
    def users_db
      Users.db.execute(
        "create table #{TABLE_NAME} (
          user_id integer primary key,
          notify boolean
        )"
      )
      true
    rescue SQLite3::SQLException
      false
    end
    module_function(
      :users_db
    )
  end

  def setup(db_path = './lib/development.db')
    # Initializing database file
    self.db = SQLite3::Database.open db_path

    # Try to get custom table, if table not exists - create this one
    Create.users_db unless get_table(TABLE_NAME)
  end

  def replace(data)
    db.execute(
      "REPLACE INTO #{TABLE_NAME} (user_id, notify)
    VALUES (?, ?)", [data[:user_id], data[:notify]]
    )
  end

  # save valid data as row to database
  def save(user_id)
    db.execute(
      "INSERT INTO #{TABLE_NAME} (user_id, notify)
      VALUES (?, ?)", [user_id, true.to_s]
    )
  end

  def notify?(user_id)
    bool = db.execute(
      "SELECT notify FROM #{TABLE_NAME} WHERE user_id = #{user_id}"
    ).flatten.first
    eval(bool)
  end

  def select_all
    respond = {}
    db.execute(
      "SELECT * FROM #{TABLE_NAME}"
    ).map do |row|
      respond[row[0]] = eval(row[1])
    end
    respond
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
    :select_all,
    :notify?,
    :replace,
    :setup,
    :save,
    :db,
    :db=
  )
end
