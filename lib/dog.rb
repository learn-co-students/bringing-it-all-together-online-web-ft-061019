class Dog
   attr_accessor :name, :breed, :id

   @@all = []

   def initialize(id=nil, attrib_hash)      
      attrib_hash.map do |attrib_key, attrib_value|
         self.send("#{attrib_key.to_s}=", attrib_value)
      end
      self
   end

   def self.create(id: nil, name:, breed:)
      attrib_hash = {:id => id, :name => name, :breed => breed}
      new_dog_from_hash = Dog.new(attrib_hash)
      new_dog_from_hash.save
      new_dog_from_hash
   end

   def self.create_table
      sql_create_table = <<-SQL
         CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
         );
      SQL
      
      DB[:conn].execute(sql_create_table)
   end
   
   def self.drop_table
      sql_drop = "DROP TABLE IF EXISTS dogs;"
      DB[:conn].execute(sql_drop)
   end
   
   #Saves an Instance of a Dog to the DB
   def save
      if self.id
         self.update
         #nothing for now
      else
      #may want to search if there is an existing version of it in the DB first
      #then just write it - below is db writing code assuming didn't find another one in the db first. 
      sql_save_to_db = <<-SQL
         INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL
         
      DB[:conn].execute(sql_save_to_db, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
      end
   end

   def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
      Dog.create(id: id, name: name, breed: breed)
   end
   
   def self.find_by_id(id)
      sql_find = "SELECT * FROM dogs WHERE id = ?"
      found = DB[:conn].execute(sql_find, id)[0]
      if !found.empty? 
         self.new_from_db(found)
      end
   end
   
   def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * from dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty? 
         found_id, found_name, found_breed = dog[0]
         doggy_hash = {:id => found_id, :name => found_name, :breed => found_breed}
         dog = Dog.new(doggy_hash)
      else
         dog = self.create(name: name, breed: breed)
      end
   end

   # Find a dog by name FROM THE DB
   def self.find_by_name(name)
      found_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
      self.new_from_db(found_dog)
   end
   
   def update
      sql_update = <<-SQL
         UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
      SQL

      DB[:conn].execute(sql_update, self.name, self.breed, self.id)
   end
   

   def self.all
      @@all
   end
end