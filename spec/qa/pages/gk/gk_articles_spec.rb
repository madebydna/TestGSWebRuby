# frozen_string_literal: true

require 'features/page_objects/gk_article_page'

describe 'User visits article', type: :feature, remote: true, safe_for_prod: true do
  before { visit '/gk/articles/the-new-sat/' }
  let(:page_object) { GkArticlePage.new }
  subject { page_object }
  
  it { is_expected.to have_heading }
  it { is_expected.to have_breadcrumbs }
end

describe 'User visits Spanish article', type: :feature, remote: true, safe_for_prod: true do
  before { visit '/gk/articles/por-que-tantos-estudiantes-destacados-terminan-en-clases-de-recuperacion/?lang=es' }
  let(:page_object) { GkArticlePage.new }
  subject { page_object }
  
  it { is_expected.to have_heading }
  its(:heading) { is_expected.to have_text('¿Por qué tantos estudiantes destacados terminan en clases de recuperación?') }
  it { is_expected.to have_breadcrumbs }
end
