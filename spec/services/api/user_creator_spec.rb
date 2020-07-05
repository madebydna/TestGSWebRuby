require "spec_helper"

describe Api::UserCreator do
  let(:user_params) do
    {
      'first_name'               => "Shannon",
      'last_name'                => "Drake",
      'organization'             => "Santos Cook Associates",
      'website'                  => "https://www.jageca.me.uk",
      'phone'                    => "+1 (242) 231-5697",
      'city'                     => "Incididunt quia enim",
      'state'                    => "co",
      'intended_use'             => "personal school search",
      'organization_description' => "real estate",
      'role'                     => "business development",
      'intended_use_details'     => "Repellendus Debitis"
    }
  end

  let(:user) { build(:api_user)}
  let(:plan_id) { 1 }

  describe '#create' do
    context 'given invalid user params' do
      it 'returns nil' do
        user.email = nil
        expect(Api::UserCreator.new(user).create)
      end
    end

  end

  def user_params(params)
    params = ActionController::Parameters.new(params)
    params.permit(:id,
                  :first_name,
                  :last_name,
                  :organization,
                  :email,
                  :website,
                  :phone,
                  :city,
                  :state,
                  :intended_use,
                  :type,
                  :account_updated,
                  :email_confirmation,
                  :organization_description,
                  :role,
                  :intended_use_details
    )
  end

end