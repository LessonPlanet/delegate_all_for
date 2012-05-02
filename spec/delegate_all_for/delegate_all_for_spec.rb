require File.expand_path('../../spec_helper', __FILE__)

# Still need to figure out how to get this to work
=begin
class Parent < ActiveRecord::Base
  def self.column_names; %w(one two) end

  has_one :child
  delegate_all_for :child, except: [:three], also_include: [:extra]

  def initialize; end
  def two; 'parent' end
end

class Child < ActiveRecord::Base
  belongs_to :parent
  def self.column_names; %w(two three four) end
  def two; 'child' end
  def extra; true end
end

describe DelegateAllFor do
  describe 'delegate_all_for' do
    subject { Parent.new }

    it { should respond_to? :three }
    it { should respond_to? :three? }
    it { should respond_to? :three= }
    it { should respond_to? :extra }
    it { should_not respond_to? :three }
    its(:two) { should == 'parent' }
  end
end
=end