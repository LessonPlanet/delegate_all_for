# DelegateAllFor

The primary driver for creating this gem was to create an easy way to accomplish the
[Multiple Table Inheritance](http://techspry.com/ruby_and_rails/multiple-table-inheritance-in-rails-3/)
pattern in active record.  delegate_all_for allows for easy [delegation](http://apidock.com/rails/Module/delegate)
of all the columns of an ActiveRecord association, including the getter, setter, and predicate for each column.

## Usage

```ruby
class Parent < ActiveRecord::Base
  has_one :child
  # columns: name
  delegate_all_for :child, except: [:sort], also_include: [:extra_method], allow_nil: true
end

class Child < ActiveRecord::Base
  belongs_to :parent
  # columns: name, description, sort
  def extra_method; 'a little extra' end
end

Parent.new.description # Delegated to Child
Parent.new.description? # Delegated to Child
Parent.new.description= # Delegated to Child
Parent.new.extra_method # Delegated to Child
Parent.new.name # Still comes from Parent
Parent.new.sort # method_missing
```

## Installation

Add this line to your application's Gemfile:

    gem 'delegate_all_for'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install delegate_all_for

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

* Inspiration for how to do it came from [Delegating Your Attributes](http://killswitchcollective.com/articles/21_delegating_your_attributes)
