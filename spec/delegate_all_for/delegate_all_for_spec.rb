require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../support/active_record', __FILE__)

class Child < ActiveRecord::Base
  belongs_to :parent
  def two; 'child' end
  def extra; true end
end

class Parent < ActiveRecord::Base
  has_one :child
  delegate_all_for :child, except: [:three], also_include: [:extra]
  def two; 'parent' end
end


describe DelegateAllFor do
  describe 'delegate_all_for' do
    subject do
      Parent.create(one: 1) do |p|
        p.two = 2
        p.child = Child.create(two: 'two', three: 'three', four: 'four')
      end
    end

    context 'does not respond to three' do
      it 'accessor' do
        lambda { subject.three }.should raise_error NoMethodError
      end
      it 'predicate' do
        lambda { subject.three? }.should raise_error NoMethodError
      end
      it 'setter' do
        lambda { subject.three = 'THREE' }.should raise_error NoMethodError
      end
    end
    its(:four)  { should == 'four' }
    its(:extra) { should be_true }
    its(:two)   { should == 'parent' }
  end
end
