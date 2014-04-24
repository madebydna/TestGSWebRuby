module LocalizationConcerns
  extend ActiveSupport::Concern

  protected

  def is_school_for_localized_profiles
    @school.collection.nil? ? false : ('detroit'.match /#{@school.collection.name}/i)
  end
end
