module Modals
  def self.included(page_class)
    page_class.class_eval do
      element :modals, '.js-modal-container .gs-modal', visible: true

      def close_all_modals
        page.execute_script('$(".js-modal-container .modal").modal("hide")')
      end
    end
  end
end