require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../support/active_record', __FILE__)

class Child < ActiveRecord::Base
  belongs_to :parent
  def two; 'child' end
  def extra; true end
end

class Parent < ActiveRecord::Base
  has_one :child
  delegate_all_for :child, except: [:three], also_include: [:extra], allow_nil: true
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

    describe ':except option' do
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

    describe ':also_include option' do
      its(:extra) { should be_true }
    end

    describe ':allow_nil option' do
      subject { Parent.new }
      its(:four) { should be_nil }
      it 'does not set allow_nil on setters' do
        lambda { subject.four = 'FOUR' }.should raise_error RuntimeError
      end
    end

    describe 'delegates to child attributes' do
      its(:four)  { should == 'four' }
      its(:two)   { should == 'parent' }

      it 'does not delegate to association attributes' do
        lambda { subject.parent_id }.should raise_error NoMethodError
      end

      it 'does not delegate to timestamp attributes' do
        lambda { subject.created_at }.should raise_error NoMethodError
      end
    end

    describe 'guards against user error' do
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
