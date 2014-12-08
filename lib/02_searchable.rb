require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    where_line = params.map do |attr_name, val| 
        attr_name.to_s.concat(" = ?")
      end.join("AND ")

    values = params.inject([]) { |accum, (attr_name, val)| accum << val }

    fetched_data = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    self.parse_all(fetched_data)
  end
end

class SQLObject
  extend Searchable
end
