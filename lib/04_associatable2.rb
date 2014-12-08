require_relative '03_associatable'

module Associatable
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_opts = self.class.assoc_options[through_name]

      source_opts =
        through_opts.model_class.assoc_options[source_name]

      through_table = through_opts.table_name
      through_pk = through_opts.primary_key
      through_fk = through_opts.foreign_key

      source_table = source_opts.table_name
      source_pk = source_opts.primary_key
      source_fk = source_opts.foreign_key

      key_val = self.send(through_fk)

      data = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

      source_opts.model_class.parse_all(data).first
    end
  end
end
