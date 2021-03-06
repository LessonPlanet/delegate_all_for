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
  # [:prefix]
  #   Prefixes accessors.  See the <tt>delegate</tt> documentation.
  # [:allow_nil]
  #   Allows accessor to be nil.  See the <tt>delegate</tt> documentation.
  def delegate_all_for(*attr_names)
    return unless self.table_exists?
    options = { except: [], also_include: [], prefix: false, allow_nil: false }
    options.update(attr_names.extract_options!)
    options.assert_valid_keys(:except, :also_include, :prefix, :allow_nil)

    exclude_columns = self.column_names.dup.concat(options[:except].map(&:to_s))
    attr_names.each do |association_name|
      if reflection = reflect_on_association(association_name)
        to = association_name
        delegate_opts = options.slice(:prefix, :allow_nil).merge(to: to)
        method_prefix = delegate_opts[:prefix] ? "#{prefix == true ? to : prefix}_" : ''

        options[:also_include].each do |m|
          class_eval(%{delegate :#{m}, #{delegate_opts}})
        end

        (reflection.klass.column_names - exclude_columns).each do |method|
          next if method.in?(reflection.foreign_key, 'updated_at', 'updated_on', 'created_at', 'created_on')
          class_eval <<-eoruby, __FILE__, __LINE__ + 1
            delegate :#{method},  #{delegate_opts}
            delegate :#{method}?, #{delegate_opts}
            delegate :#{method}=, #{delegate_opts.merge(allow_nil: false)} # allow_nil true leads to unintuitive behavior
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
