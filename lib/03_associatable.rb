require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name  = options[:class_name]  || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || name.to_s.concat("_id").underscore.to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name  = options[:class_name]  || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || self_class_name.to_s.concat("_id").underscore.to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      fk_val = self.send(options.foreign_key)

      options
        .model_class
        .where(options.primary_key => fk_val)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] =
       HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      p_val = self.send(options.primary_key)

      options
        .model_class
        .where(options.foreign_key => p_val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
