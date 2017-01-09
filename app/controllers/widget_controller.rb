class WidgetController < ApplicationController

  layout :determine_layout

  def show

  end

  def map

  end

  def create

  end

  private

  def determine_layout
    application_layout = ['show']
    widget_map_layout = ['map']

    if application_layout.include?(action_name)
      'application'
    elsif widget_map_layout.include?(action_name)
      'widget_map'
    else
      'false'
    end
  end
end
