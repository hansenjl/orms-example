class Tweet
    attr_accessor :content, :author
    attr_reader :id

    def initialize(content:, author:, id: nil)
        @content, @author, @id = content, author, id
    end

    def self.create(content: , author:, id: nil )
        self.new(content: content, author: author, id: id).save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM tweets WHERE id = ?;
        SQL
        result = DB.execute(sql, id)
        self.map_from_db(result).first
    end

    def self.find_by_author(author)
        # NOTE: This lookup is CASE INSENSITIVE
        sql = <<-SQL
            SELECT * FROM tweets
            WHERE lower(author) = ?;
        SQL
        return self.map_from_db(DB.execute(sql, author.downcase))
    end

    def self.find_by_content(content)
        sql = <<-SQL
            SELECT * FROM tweets
            WHERE lower(content) like ?
        SQL
        return self.map_from_db(DB.execute(sql, "%#{content.downcase}%"))
    end

    def self.delete_by_id(id)
        sql = <<-SQL
            DELETE FROM tweets WHERE id = ?;
        SQL
        DB.execute(sql,id)
    end

    def self.count
        sql = <<-SQL
            SELECT count(*) FROM tweets;
        SQL
        data = DB.execute(sql)
        data[0][0]
    end

    def save
        if saved?
            sql = <<-SQL
                UPDATE tweets
                SET content = ?, author = ?
                WHERE id = ?;
            SQL
            DB.execute(sql, self.content, self.author, self.id)
        else
            sql = <<-SQL
                INSERT INTO tweets (content, author)
                VALUES (?,?);
            SQL
            DB.execute(sql, self.content, self.author)
            @id = DB.last_insert_row_id
            # @id = DB.execute("SELECT last_insert_rowid() FROM tweets")[0][0]
        end
        self
    end

    def saved?
        !self.id.nil? && !!Tweet.find_by_id(self.id)
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM tweets;
        SQL

        self.map_from_db(DB.execute(sql))
    end

    def self.map_from_db(array_or_hash)
        if array_or_hash.is_a?(Array)
            array_or_hash.map do |tweet_hash|
                self.new(content: tweet_hash["content"], author: tweet_hash["author"], id: tweet_hash["id"])
            end
        elsif array_or_hash.is_a?(Hash)
            self.new(content: array_or_hash["content"], author: array_or_hash["author"], id: array_or_hash["id"])
        else
            raise ArgumentError.new("Unexpected datatype")
        end
    end

    def self.make_table
        sql =  <<-SQL
            CREATE TABLE IF NOT EXISTS tweets (
            id INTEGER PRIMARY KEY,
            content TEXT,
            author TEXT
            )
        SQL
        DB.execute(sql)
    end


end