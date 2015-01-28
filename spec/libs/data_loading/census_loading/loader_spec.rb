require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe CensusLoading::Loader do

  it_behaves_like 'a loader', CensusLoading::Loader

end