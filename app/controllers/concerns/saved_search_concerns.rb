module SavedSearchConcerns
  extend ActiveSupport::Concern

  protected

  def create_saved_search(saved_search_params)
    begin
      name = saved_search_params[:name]
      num_of_searches_with_same_name = current_user.saved_searches.num_of_prev_searches_named(name)

      saved_search_params[:name] = "#{name}(#{num_of_searches_with_same_name})" if num_of_searches_with_same_name > 0
      current_user.saved_searches.create!(saved_search_params)
      true
    rescue => e
      puts e.message
      flash_error 'Your saved search was missing fields'
    end
  end
end
