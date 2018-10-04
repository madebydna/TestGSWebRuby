module SchoolHelper

  def draw_stars_16(on_star_count)
    draw_stars 16, on_star_count
  end

  def draw_stars_24(on_star_count)
    draw_stars 24, on_star_count
  end

  def draw_stars_48(on_star_count)
    draw_stars 48, on_star_count
  end

  # this is the single place to reference naming for school type
  def school_type_display(type)
    school_types_map = {
        charter: 'Public charter',
        public: 'Public district',
        private: 'Private'
    }
    school_types_map[type.to_s.downcase.to_sym]
  end

  #####################################################################################################################
  #
  #   supporting functions only used in this helper
  #
  #####################################################################################################################

  def draw_stars(size, on_star_count)
    off_star_count = 5 - on_star_count
    class_on = "iconx#{size}-stars i-#{size}-orange-star i-#{size}-star-#{on_star_count}"
    class_off = "iconx#{size}-stars i-#{size}-grey-star i-#{size}-star-#{off_star_count}"
    content_tag(:span, '', :class => class_on) + content_tag(:span, '', :class => class_off)
  end

end