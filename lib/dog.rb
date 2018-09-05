class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id: nil)
      @id = id 
      @name = name
      @breed = breed 
  end 
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY, 
    name TEXT, 
    breed TEXT 
    )
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs 
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self 
  end 
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end 
  
  def self.new_from_db(row)
      dog = Dog.new(name: row[1],breed: row[2],id: row[0])
      dog
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id =?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first 
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      dog = Dog.create(name: name, breed: breed)
    end 
    dog
  end 
  
  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    dog_data = dog[0]
    Dog.find_or_create_by(name: dog_data[1])
  end 
  
end 