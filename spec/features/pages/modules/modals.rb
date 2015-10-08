module Modals
  def self.included(page_class)
    page_class.class_eval do
      element :modals, '.js-modal-container .gs-modal', visible: true
    end
  end
end