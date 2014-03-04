require 'sqlite3'

class GFDatabase

  TABLE_NAME = 'gfs'
  DB_NAME = 'db/gfs.sqlite'

  def initialize()
    @db = SQLite3::Database.new(DB_NAME)
    setup
  end

  def all
    @db.execute("""
      SELECT
        id,
        name,
        rarity,
        image_src,
        amount
      FROM #{TABLE_NAME}
    """).inject(Array.new) {|result, row|
      result << convert_to_hash(row)
    }
  end

  def save(name, rarity, image_src)
    exists = find(name, rarity)
    if exists.empty?
      insert name, rarity, image_src
    else
      update exists.first[:id], exists.first[:amount]
    end
  end

  def close
    @db.close
  end

  def clean
    drop_table_sql = """
      DELETE FROM #{TABLE_NAME} WHERE 1=1;
    """
    @db.execute(drop_table_sql)
  end

private
  def setup
    @db.execute("""
      CREATE TABLE IF NOT EXISTS #{TABLE_NAME} (
          id integer PRIMARY KEY AUTOINCREMENT,
          name text,
          rarity text,
          image_src text,
          amount integer
        );
    """)
  end

  def insert(name, rarity, image_src)
    @db.execute("""
      INSERT INTO #{TABLE_NAME}
        (name, rarity, image_src, amount)
      VALUES (
        '#{name}',
        '#{rarity}',
        '#{image_src}',
        1
      );
    """)
  end

  def update(id, current_amount)
    @db.execute("""
      UPDATE #{TABLE_NAME} SET amount = #{current_amount+1} WHERE id = #{id};
    """)
  end

  def find(name, rarity)
    @db.execute("""
      SELECT id, name, rarity, image_src, amount
      FROM #{TABLE_NAME}
      WHERE name = '#{name}' AND rarity = '#{rarity}';
    """).inject(Array.new) {|result, row|
      result << convert_to_hash(row)
    }
  end

  def convert_to_hash(row)
    {
      :id => row[0],
      :name => row[1],
      :rarity => row[2],
      :image_src => row[3],
      :amount => row[4]
    }
  end

end


