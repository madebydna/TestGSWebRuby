module StateCacheValidation

  include StateDataValidation

  def validate!(cache)
    @cache = cache

    # List the methods you want to run here.
    # Note that order is important!
    validate_format!

    @cache
  end

  def remove_empty_values!
    @cache.keep_if do | char_type, values |
      values.present? || (log_data_rejection(@state,char_type,"No value found") && false)
    end
  end

  # Place validation methods below this comment.
  # Validations will be executed in the order that they are listed here.
  # Please give methods understandable names and logic with
  # comments when necessary. The goal is for a wide audience to
  # understand this business logic.

  def validate_format!
    remove_empty_values!
  end



end
