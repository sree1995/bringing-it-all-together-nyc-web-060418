class Dog

  attr_accessor :name, :breed, :id

  def initialize(props = {})
    @name = props[:name]
    @breed = props[:breed]
    @id = props[:id]
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql=<<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    dog = self.new
    dog.name = name
    dog.breed = breed
    dog.save
  end

  def self.find_by_id(id)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, id)[0]

    Dog.new(name: dog_array[1], breed: dog_array[2], id: dog_array[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND
      breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      dog_row = dog[0]
      new_dog = self.new(name: dog_row[1], breed: dog_row[2], id: dog_row[0])
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql=<<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      where id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)

    self
  end




end
