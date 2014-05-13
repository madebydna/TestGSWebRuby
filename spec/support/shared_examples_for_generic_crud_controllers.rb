shared_examples_for 'controller with generic update method' do |model_class|
  describe '#update' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should update object if one is found' do
      object = double(model_class)
      allow(model_class).to receive(:find).and_return(object)
      expect(object).to receive(:update_attributes).and_return true
      post :update, id: 1
    end

    it 'should handle update failure by setting flash message' do
      object = double(model_class).as_null_object
      allow(model_class).to receive(:find).and_return(object)
      expect(object).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1
    end
  end
end

shared_examples_for 'controller with generic create method' do |model_class|
  describe '#create' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
      @params = { "#{model_class.name.underscore}" => [] }.symbolize_keys!
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should set flash notice on successful save' do
      expect_any_instance_of(model_class).to receive(:save).and_return true
      expect(controller).to receive(:flash_notice)
      post :create, @params
    end

    it 'should handle create failure by setting flash message' do
      expect_any_instance_of(model_class).to receive(:save).and_return false
      expect(controller).to receive(:flash_error)
      post :create, @params
    end
  end
end

shared_examples_for 'controller with generic destroy method' do |model_class|
  describe '#destroy' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
      @params = { "#{model_class.name.underscore}" => [] }.symbolize_keys!
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should set flash notice on successful destruction' do
      object = double(model_class)
      expect(model_class).to receive(:find).and_return(object)
      expect(object).to receive(:destroy).and_return true
      expect(controller).to receive(:flash_notice)
      post :destroy, id: 1
    end

    it 'should handle destroy failure by setting flash message' do
      object = double(model_class)
      expect(model_class).to receive(:find).and_return(object)
      expect(object).to receive(:destroy).and_return false
      expect(controller).to receive(:flash_error)
      post :destroy, id: 1
    end

    it 'should flash error message if object not found by ID' do
      expect(model_class).to receive(:find).and_return nil
      expect_any_instance_of(model_class).to_not receive(:destroy)
      expect(controller).to receive(:flash_error)
      post :destroy, id: 1
    end
  end
end
