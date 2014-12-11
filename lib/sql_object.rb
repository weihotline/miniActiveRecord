require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    query = <<-SQL
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    DBConnection.execute2(query).first.map { |col_name|  col_name.to_sym }
  end

  def self.finalize!
    col_names = self.columns 
    
    col_names.each do |col_name|
      # setter
      define_method "#{col_name}=" do |val|
        table = self.attributes
        table[col_name] = val
      end

      # getter
      define_method "#{col_name}" do
        table = self.attributes
        table[col_name]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT 
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    self.parse_all(data)
  end

  def self.parse_all(results)

    [].tap do |object_data|
      results.each { |attr| object_data << self.new(attr) }
    end
  end

  def self.find(id)
    fetched_data = DBConnection.execute(<<-SQL, id)
      SELECT 
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    self.parse_all(fetched_data).first
  end

  def initialize(params = {})
    unless params.empty?
      params.each do |attr_name, val|

        if self.class.columns.include?("#{attr_name}".to_sym)
          self.send("#{attr_name}=", val)
        else
          raise "unknown attribute '#{attr_name}'"
        end
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.inject([]) do |values, col_name| 
      values << self.send("#{col_name}")
    end
  end

  def insert
    col_names = self.class.columns
    question_marks = (["?"] * col_names.count).join(", ")
    col_names = col_names.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.send("#{:id}=", DBConnection.last_insert_row_id)
  end

  def update
    set_line = self.class.columns.map do |attr_name| 
        attr_name.to_s.concat(" = ?")
      end.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end
