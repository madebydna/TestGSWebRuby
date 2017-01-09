class WidgetController < ApplicationController

  layout :determine_layout

  # this is the form for getting the widget
  def show

  end

  # this is the widget iframe component
  def map

  end

  # this is the widget iframe component - that will contain all the content
  def gs_map

  end

  # form submission support - ajax - need to create model and db schema for this as well
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
