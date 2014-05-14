describe CategoryPlacementPresenter do
  let(:page_config) { double(PageConfig).as_null_object }
  let(:view) { double('view').as_null_object }
  subject do
    CategoryPlacementPresenter.new(
      category_placement,
      page_config,
      view
    )
  end

  describe '#wrapper_layout' do
    let(:category_placement) do
      FactoryGirl.build(:category_placement, title: nil)
    end

    it 'returns nil if category placement has no title' do
      expect(subject.wrapper_layout).to be_nil
    end
  end

  describe '#module_specific_partial' do
    let(:category_placement) do
      FactoryGirl.build(:category_placement, title: 'test', layout: 'layout')
    end

    it 'should not find module wrapper layout data_layouts/test_layout' do
      expect(subject.module_specific_partial).to be_nil
    end

    it 'should find module wrapper layout data_layouts/_programs_section' do
      category_placement.title = 'Programs'
      category_placement.layout = 'section'
      expect(subject.module_specific_partial)
        .to eq('data_layouts/programs_section')
    end
  end

  describe '#render' do
    before(:each) do
      allow(view).to receive(:params).and_return({ controller: '' })
    end

    context 'when module specific layout wrapper exists' do
      let(:category_placement) do
        FactoryGirl.build(
          :category_placement,
          title: 'Programs',
          layout: 'section'
        )
      end
      it 'two partials should be rendered' do
        # expect(view).to receive(:render) { yield if block_given }.twice
        expect(view).to receive(:render)
          .with(layout: 'data_layouts/programs_section', locals: Hash)
        subject.render
      end
    end

    context 'when module specific layout wrapper does not exist' do
      let(:category_placement) do
        FactoryGirl.build(
          :category_placement,
          title: 'dsfdfs',
          layout: 'sdfd'
        )
      end
      it 'two partials should be rendered' do
        expect(view).to receive(:render).with(subject.default_partial, Hash)
        subject.render
      end
    end
  end
  
end