require 'test_helper'

class ActiveRecordFindersTest < Test::Unit::TestCase
  def self.grey_ghost_user
    @@grey_ghost_user ||= User.find_or_create_by_username('GREYGHOST')
  end

  def self.should_find_the_record_using(eval_string)
    context 'When a user with username "GREYGHOST" exists' do
      setup do
        @grey_ghost_user = self.class.grey_ghost_user
      end

      %w(GREYGHOST greyGhost Greyghost GreyGhost greyghost).each do |username|
        context_eval_string = eval_string % username
        context "finding a user record using #{context_eval_string}" do
          setup do
            @user = instance_eval(context_eval_string)
          end

          should 'find the record' do
            assert_equal @grey_ghost_user, @user
          end
        end
      end
    end
  end

  should_find_the_record_using "User.find(:first, :conditions => { :username => '%s' })"
  should_find_the_record_using "User.find_by_username('%s')"
  should_find_the_record_using "User.find(:first, :conditions => ['username = ?', '%s'])"
  should_find_the_record_using "User.find(:first, :conditions => ['username = :u', { :u => '%s' }])"

  context 'Creating a new user with username "MixedCase"' do
    setup do
      @user = User.create!(:username => 'MixedCase')
    end

    should 'not modify the casing when saving the record' do
      assert_equal 'MixedCase', @user.reload.username
    end
  end
end