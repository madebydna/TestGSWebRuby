class WidgetController < ApplicationController

  layout 'application', only: [:show]
  layout 'widget_map', only: [:show]
  layout false, only: [:create]

  def show

  end

  def map

  end

  def create

  end

end
