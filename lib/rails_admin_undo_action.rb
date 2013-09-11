require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Undo < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :route_fragment do
          'undo'
        end

        register_instance_option :link_icon do
          'icon-step-backward'
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          Proc.new do
            #@object.update_attribute(:approved, true)

            if request.get? # request undo
              if @object.previous_version
                @object = @object.previous_version
                respond_to do |format|
                  format.html { render @action.template_name }
                  format.js   { render @action.template_name, :layout => false }
                end
              else
                flash[:error] = 'Cannot undo, since there is no previous version of this object'
                redirect_to index_path
              end
            elsif request.post? # actually undo
              redirect_path = nil

              if @object.previous_version
                if @object.previous_version.save
                  flash[:success] = 'Undo successful.'
                  redirect_path = index_path
                end

                redirect_to redirect_path
              else
                flash[:error] = 'Cannot undo, since there is no previous version of this object'
                redirect_to index_path
              end
            end
          end
        end
      end
    end
  end
end