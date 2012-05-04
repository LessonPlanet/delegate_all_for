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
      it 'reader' do
        lambda { subject.three }.should raise_error NoMethodError
      end
      it 'predicate' do
        lambda { subject.three? }.should raise_error NoMethodError
      end
      it 'writer' do
        lambda { subject.three = 'THREE' }.should raise_error NoMethodError
      end
    end

    context 'delegates to child attributes' do
      its(:four)  { should == 'four' }
      its(:extra) { should be_true }
      its(:two)   { should == 'parent' }

      it 'does not delegate to association attributes' do
        lambda { subject.parent_id }.should raise_error NoMethodError
      end

      it 'does not delegate to timestamp attributes' do
        lambda { subject.created_at }.should raise_error NoMethodError
      end
    end

    context 'guards against user error' do
      it 'notices when an association is wrong' do
        lambda do
          class Parent < ActiveRecord::Base
            has_one :child
            delegate_all_for :foo
          end
        end.should raise_error ArgumentError
      end
    end
  end
end
