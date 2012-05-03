require 'active_record'
require 'active_record/version'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'delegate_all_for/version'

$LOAD_PATH.shift

module DelegateAllFor
  # For all columns of the specified association to the current object,
  # the reader, writer, and predicate methods are delegated.
  #
  # Supported options:
  # [:except]
  #   An array of column names to exclude from delegation
  # [:also_include]
  #   An array of method names to also delegate
  def delegate_all_for(*attr_names)
    options = { except: [], also_include: [] }
    options.update(attr_names.extract_options!)
    options.assert_valid_keys(:except, :also_include)

    exclude_columns = self.column_names.dup.concat(options[:except].map(&:to_s))
    attr_names.each do |association_name|
      if reflection = reflect_on_association(association_name)
        options[:also_include].each do |m|
          class_eval(%{delegate :#{m}, :to => :#{association_name}})
        end
        (reflection.klass.column_names - exclude_columns).each do |column_name|
          class_eval <<-eoruby, __FILE__, __LINE__ + 1
            delegate :#{column_name}, :to => :#{association_name}
            delegate :#{column_name}=, :to => :#{association_name}
            delegate :#{column_name}?, :to => :#{association_name}
          eoruby
        end
      else
        raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
      end
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend DelegateAllFor
end
