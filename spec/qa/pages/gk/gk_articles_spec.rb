# frozen_string_literal: true
require 'features/page_objects/gk_article_page'

describe 'User visits article', type: :feature, remote: true, safe_for_prod: true do
  subject { GkArticlePage.new }

  before do 
    subject.load(slug: 'the-new-sat')
  end
  
  it { is_expected.to have_heading }
  it { is_expected.to have_breadcrumbs }
end

describe 'User visits Spanish article', type: :feature, remote: true, safe_for_prod: true do
  subject { GkArticlePage.new }

  before do 
    subject.load(slug: 'por-que-tantos-estudiantes-destacados-terminan-en-clases-de-recuperacion', query: {lang: 'es'})
  end
  
  it { is_expected.to have_heading }
  its(:heading) { is_expected.to have_text('¿Por qué tantos estudiantes destacados terminan en clases de recuperación?') }
  it { is_expected.to have_breadcrumbs }
end
