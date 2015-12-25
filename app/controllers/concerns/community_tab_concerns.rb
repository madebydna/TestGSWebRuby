module CommunityTabConcerns

  protected

  def get_community_tab_from_request_path(path, show_tabs)
    case path
    when /(education-community\/education)/
     return 'Education'
    when /(education-community\/funders)/
      return 'Funders'
    when /(education-community$)/
      if show_tabs == false
        return ''
      else
        return 'Community'
      end
    end
  end

end
