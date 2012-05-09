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
          eoruby

          # Create the setter with support for using nested attributes to set it if the delegated object is not present
          exception = %(raise "#{self}##{method_prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")
          class_eval <<-eoruby, __FILE__, __LINE__ + 1
            def #{method_prefix}#{method}=(*args, &block)                             # def customer_name(*args, &block)
              if #{to} || #{to}.respond_to?(:#{method})                               #   if client || client.respond_to?(:name)
                #{to}.__send__(:#{method}=, *args, &block)                            #     client.__send__(:name, *args, &block)
              elsif self.respond_to?(:#{to}_attributes=)                              #   elsif self.respond_to?(:client_attributes=)
                self.__send__(:#{to}_attributes=, :#{method} => args.first, &block)   #     self.__send__(:client_attributes=, :name => args.first, &block)
              else                                                                    #   else
                #{exception}                                                          #     # add helpful exception
              end                                                                     #   end
            end                                                                       # end
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
