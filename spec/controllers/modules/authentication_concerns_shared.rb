require 'spec_helper'

shared_examples_for "controller with authentication" do

  describe '#current_user' do

    it 'should return @current_user if already set, even if no user_id \
 in session' do
      user = double('user')
      controller.instance_variable_set(:@current_user, user)
      expect(controller.send :current_user).to eq user
    end

  end
end