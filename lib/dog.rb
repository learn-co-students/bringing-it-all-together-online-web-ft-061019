class Dog
    attr_accessor :name, :breed, :id
    def initialize(args)
        args.each {|key, value| self.send("#{key}=", value)}
    end

#   it 'creates a dogs table' do
#     DB[:conn].execute('DROP TABLE IF EXISTS dogs')
#     Dog.create_table

#     table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
#     expect(DB[:conn].execute(table_check_sql)[0]).to eq(['dogs'])
#   end
# end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    end

    def self.new_from_db(row)
        self.new({"id": row[0], "name": row[1], "breed": row[2] })
        # row.map do |row|

        # end
    end

    def save
        if self.id.nil?
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
        else
            # When there is no id...
            binding.pry
        end
        self
    end

    def self.create(args)
        self.new(args).tap{|dob_obj| dob_obj.save}

    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        self.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = self.new_from_db(dog_data)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        self.new_from_db(DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0])
    end

    def update
        DB[:conn].execute('UPDATE dogs SET breed = ?, name = ? WHERE id = ?', self.breed, self.name, self.id)
    end

end