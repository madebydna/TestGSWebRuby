require 'spec_helper'
require 'controllers/contexts/osp_shared_contexts'
require 'features/contexts/osp_contexts.rb'

describe OspRegistrationController do
  describe '#new' do
    it 'should have correct osp page meta tag' do
      allow(controller).to receive(:set_meta_tags)
    end

    it 'should have correct omniture tracking' do
      allow(controller).to receive(:set_omniture_data_for_school)
      allow(controller).to receive(:set_omniture_data_for_user_request)
    end

    with_shared_context 'visit registration page with no state or school' do
      it ' should render correct error page' do
        expect(response).to render_template('osp/registration/no_school_selected')
      end
    end

    with_shared_context 'Delaware public school' do
      with_shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do
        it ' should render correct error page' do
          expect(response).to render_template('osp/registration/delaware')
        end
      end
    end

    with_shared_context 'Delaware charter school' do
      with_shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do
        it ' should render correct error page' do
          expect(response).to render_template('osp/registration/delaware')
        end
      end
    end

    with_shared_context 'Delaware private school' do
      with_shared_context 'visit registration page with school state and school' do
        it ' should render correct registration page' do
          expect(response).to render_template('osp/registration/new')
        end
      end
    end

    with_shared_context 'Basic High School' do
      with_shared_context 'visit registration page with school state and school' do
        it ' should render correct registration page' do
          expect(response).to render_template('osp/registration/new')
        end
      end
    end

    # with_shared_context 'Basic High School' do
    #   with_shared_context 'signed in approved osp user for school' do
    #     with_shared_context 'visit registration page with school state and school' do
    #       it 'should redirect osp user to school osp form' do
    #         expect(response).to render_template(osp_page_path(page: 1, schoolId: school.id, state: school.state))
    #       end
    #     end
    #   end
    # end

    #TODO: finish this test when official-school-profile/dashboard is a ruby page
    # with_shared_context 'Basic High School' do
    #   with_shared_context 'signed in approved osp user for school' do
    #     with_shared_context 'visit registration page with school state and school' do
    #       it 'should redirect osp user to school osp form' do
    #         save_and_open_page
    #         expect(response).to redirect_to('/official-school-profile/dashboard/')
    #       end
    #     end
    #   end
    # end

  end
end
