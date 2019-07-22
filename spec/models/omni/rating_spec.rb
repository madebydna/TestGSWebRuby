# frozen_string_literal: true

require 'spec_helper'

describe Rating do
  # after { clean_dbs :gsdata }
  #
  it 'does something' do
    r = Rating.create
    expect(r.class).to eq(Rating)
  end

  it 'doesnt remove data' do
    expect(Rating.count).to eq(0)
  end

end
