require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe EspResponseLoading::Loader do

  it_behaves_like 'a loader', EspResponseLoading::Loader

end