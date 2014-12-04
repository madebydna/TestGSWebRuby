#encoding: utf-8

module WritePdfConcerns

  RECT_EDGE_ROUNDING = 10
  DARK_BLUE = 70, 15, 0, 0
  WHITE = 0, 0, 0, 0
  GREY = 0, 0, 0, 6
  BLACK = 0, 0, 0, 100
  DARK_GREY = 0, 0, 0, 51
  LIGHT_BLUE = 5, 1, 0, 0
  COL_WIDTH = 170

  FONT_SIZE_7 = 7
  FONT_SIZE_8 = 8
  FONT_SIZE_9 = 9

  IMAGE_PATH_SCHOOL_SIZE= "app/assets/images/pyoc/school_size_pyoc.png"
  IMAGE_PATH_TRANSPORTATION= "app/assets/images/pyoc/transportation_pyoc.png"
  IMAGE_PATH_BEFORE_CARE= "app/assets/images/pyoc/before_care_pyoc.png"
  IMAGE_PATH_AFTER_CARE= "app/assets/images/pyoc/after_care_pyoc.png"
  IMAGE_PATH_UNIFORM= "app/assets/images/pyoc/uniform_pyoc.png"
  IMAGE_PATH_PRE_K= "app/assets/images/pyoc/pre_k_pyoc.png"

  IMAGE_PATH_WORLD_LANGUAGES = "app/assets/images/pyoc/world_languages.png"
  IMAGE_PATH_CLUBS = "app/assets/images/pyoc/clubs.png"
  IMAGE_PATH_SPORTS = "app/assets/images/pyoc/sports.png"
  IMAGE_PATH_VISUAL_ARTS = "app/assets/images/pyoc/visual_arts.png"
  NO_PROGRAM_DATA = "?"

  IMAGE_SCALE_25 = 0.25

  def generate_schools_pdf(get_page_number_start, is_high_school_batch, is_k8_batch, is_pk8_batch, schools_decorated_with_cache_results, collection_id)
    start_time = Time.now
    define_grid(:columns => 6, :rows => 9, :gutter => 15)

    position_on_page = 0

    schools_decorated_with_cache_results.each_with_index do |school, index|

      if index % 3 == 0 and index != 0
        start_new_page()
        position_on_page = 0
      end

      if index % 3 != 0
        position_on_page += 3
      end

      puts "#{self.class} - Generating PYOC PDF for School ID - #{school.id} ,State #{school.state} "

      draw_header(is_k8_batch, is_high_school_batch, is_pk8_batch)

      school_cache = school.school_cache

      grid([position_on_page, 0], [position_on_page+2, 5]).bounding_box do
        move_down 18
        draw_first_column(school, school_cache, is_high_school_batch, is_k8_batch, is_pk8_batch)
        draw_second_column(school_cache, school)
        draw_third_column(school_cache, school)

        move_down_small
        draw_grey_line(index)
      end
    end

    draw_all_footer(get_page_number_start, collection_id)

    end_time =Time.now - start_time
    puts "#{self.class} - Time taken to generate the Schools PDF #{end_time}seconds"
  end

  def move_down_small
    move_down 5
  end

  def move_down_medium
    move_down 10
  end

  def move_down_large
    move_down 20
  end

  def move_down_15
    move_down 15
  end

  def draw_header(is_k8_batch, is_high_school_batch, is_pk8_batch)
    grade = is_spanish ? 'GRADO' : 'GRADE'

    if is_high_school_batch
      fill_color DARK_BLUE
      text_box grade + " 9-12",
               :at => [250, 745],
               :width => COL_WIDTH,
               :height => 20,
               :size => FONT_SIZE_9
      stroke do
        stroke_color DARK_BLUE
        horizontal_line 0, 546, :at => 735
      end
    elsif is_pk8_batch
      fill_color DARK_GREY
      text_box grade + " PK-8",
               :at => [250, 745],
               :width => COL_WIDTH,
               :height => 20,
               :size => FONT_SIZE_9
      stroke do
        stroke_color DARK_GREY
        horizontal_line 0, 546, :at => 735
      end
    elsif is_k8_batch
      fill_color DARK_GREY
      text_box grade + " K-8",
               :at => [250, 745],
               :width => COL_WIDTH,
               :height => 20,
               :size => FONT_SIZE_9
      stroke do
        stroke_color DARK_GREY
        horizontal_line 0, 546, :at => 735
      end
    end

  end

  def draw_all_footer(page_number_start, collection_id)
    #number_pages method can just be called once and will write to all pages.
    number_pages '<page>', {:at => [270, -15], :size => FONT_SIZE_7, :start_count_at => page_number_start, :color => BLACK}
    page_count.times do |i|
      go_to_page(i+1)
      draw_logo_and_url_on_footer(collection_id)
    end
  end

  def draw_logo_and_url_on_footer(collection_id)
    image 'app/assets/images/pyoc/GS_logo-21.png', :at => [180, -10], :scale => 0.2
    text_box which_footer(collection_id, is_spanish),
             :at => [300, -15],
             :width => is_spanish ? 150 : 115,
             :height => 10,
             :size => 6,
             :style => :italic

    fill_color DARK_BLUE
    text_box which_landing_page(collection_id),
             :at => is_spanish ? [440, -15] : [420, -15],
             :width => 150,
             :height => 10,
             :size => 6,
             :style => :italic

  end

  def draw_grey_line(index)
    if index % 3 != 2
      stroke do
        stroke_color GREY
        horizontal_line 0, 540, :at => cursor
      end
    end
  end

  # first column

  def draw_first_column(school, school_cache, is_high_school_batch, is_k8_batch, is_pk8_batch)
    grid([0, 0], [2, 1]).bounding_box do
      # blue rectangle
      if is_high_school_batch
        fill_color LIGHT_BLUE
      elsif is_k8_batch || is_pk8_batch
        fill_color GREY
      end
      fill_rounded_rectangle([0, cursor], COL_WIDTH, 225, RECT_EDGE_ROUNDING)
      fill_color 100, 20, 20, 20
      move_down_small

      draw_name_grade_type_and_district(school, school_cache)

      move_down_15

      draw_overall_gs_rating(school_cache)
      draw_other_gs_ratings_table(school_cache)

      move_down_medium

      stroke do
        stroke_color GREY
        horizontal_line 5, (COL_WIDTH - 5), :at => cursor
      end

      move_down_small

      other_ratings = school_cache.formatted_non_greatschools_ratings.to_a

      if other_ratings == []
        move_down_medium
      else
        other_state_ratings(school_cache, school)
        move_down_small
      end

      draw_address(school)

      map_icon = draw_map_icon(school)
      if map_icon != 'N/A'
        bounding_box([1, 70], :width => 0, :height => 0) do
          if other_ratings == []
            move_down_small
          else
            move_down_large
          end
          image map_icon, :at => [15, cursor], :scale => 0.2
        end

        move_down_15

        draw_school_hours(school_cache, 60)


        move_down_small
        draw_best_known_for(school_cache, school, 60)

      else
        move_down_small
        draw_school_hours(school_cache, 15)

        move_down_small
        draw_best_known_for(school_cache, school, 15)
      end

    end
  end

  def draw_name_grade_type_and_district(school, school_cache)
    text_box school.name,
             :at => [5, cursor],
             :width => COL_WIDTH - 10,
             :height => 40,
             :size => 10,
             :style => :bold

    move_down 40
    fill_color BLACK

    # to handle detroit ungraded level
    level = format_level_ungraded(school)
    which_district_truncation(school, level)

  end

  def format_level_ungraded(school)
    if school.process_level.include?('& Ungraded')
      level = school.process_level.gsub('& Ungraded', '& UG')
    else
      level = school.process_level
    end
  end

  def truncate_district(school, char_length)
    if school.district != nil
      truncated_district = school.district.name.truncate(char_length)
    end
  end

  def which_district_truncation(school, level)
    if school.district != nil
      if level.include? '& UG'
        truncated_district = '| ' + truncate_district(school, 27)
      else
        truncated_district = '| ' + truncate_district(school, 34)
      end
    else
      truncated_district = ' '
    end


    school_type = school.which_school_type

    text_box "#{level} | #{is_spanish ? school_type : school.decorated_school_type} #{truncated_district}",
             :at => [5, cursor],
             :width => COL_WIDTH - 10,
             :height => 20,
             :size => 6
  end

  def draw_gs_rating_image(rating)
    image "app/assets/images/pyoc/overall_rating_#{rating}.png", :at => [15, cursor], :scale => IMAGE_SCALE_25
  end

  def is_spanish
    @is_spanish == true
  end

  def draw_overall_gs_rating(school_cache)
    bounding_box([1, cursor], :width => 0, :height => 0) do
      move_down 2

      draw_gs_rating_image(school_cache.overall_gs_rating)

      move_down 25
      fill_color BLACK
      text_box is_spanish ? "Calificación general" : "Overall rating",
               :at => [is_spanish ? 10 : 17, cursor],
               :width => is_spanish ? 35 : 25,
               :height => 25,
               :size => 6,
               :style => :bold

    end
  end

  def draw_other_gs_ratings_table(school_cache)
    data = get_gs_rating_info(school_cache)
    table(data, :column_widths => [80, 20],
          :position => 55,
          :cell_style => {size: 7, :height => 12, :padding => [0, 0, 1, 0], :text_color => BLACK}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
    end
  end

  def get_gs_rating_info(school_cache)
    data = [
        ["#{is_spanish ? 'Puntuación de examenes' : 'Test score rating'}", school_cache.test_scores_rating],
        ["#{is_spanish ? 'Crecimiento' : 'Student growth rating'}", school_cache.student_growth_rating],
        ["#{is_spanish ? 'Preparacion universitaria' : 'College readiness'}", school_cache.college_readiness_rating],
    ]
  end

  def other_state_rating_abbreviation(rating_name)
    rating_abbr = {'Excellent Schools Detroit Rating' => 'ESD Rating',
                   'Great Start to Quality preschool rating' => 'Preschool Rating'
    }
    rating_abbr[rating_name]
  end

  def other_state_ratings(school_cache, school)
    data =[[], []]

    other_ratings = school_cache.formatted_non_greatschools_ratings.to_a
    if other_ratings == []
      data << ['', '']
    else
      if is_spanish
        other_ratings.each do |i|
          if school.which_rating_mapping(i[0]).present?
            data[0] << (school.which_rating_mapping(i[1]).nil? ? 'NR' : school.which_rating_mapping(i[1]))
            data[1] << school.which_rating_mapping(i[0])
          else
            data[0] << i[1]
            data[1] << i[0]
          end
        end
      else
        other_ratings.each do |i|
          if other_state_rating_abbreviation(i[0])
            data[0] << i[1]
            data[1] << other_state_rating_abbreviation(i[0])
          else
            data[0] << i[1]
            data[1] << i[0]
          end
        end
      end

    end

    table(data, :column_widths => [56, 56, 56],
          :position => 5,
          :cell_style => {size: 6, :padding => [0, 0, 0, 0], :text_color => BLACK}) do
      cells.borders = []
      row(0).font_style = :bold
      row(0).size = 7
      row(0).padding = [0, 0, 5, 10]
      row(1).padding = [0, 5, 0, 0]
    end
  end

  def draw_map_icon(school)
    if school.which_icon.present? && school.which_icon != 'N/A'
      map_icon = school.which_icon
    else
      map_icon = 'N/A'
    end
  end

  def draw_address(school)
    data =[[school.street],
           ["#{school.city}, #{school.state} #{school.zipcode}"],
           ["#{is_spanish ? 'Teléfono: ' : 'Phone: ' }" + "#{school.phone}"],
    ]


    table(data,
          :position => 15,
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => BLACK}) do
      cells.borders = []
    end

  end

  def draw_school_hours(school_cache, x_position)
    data = [
        ["#{is_spanish ? 'Horario' : 'School Hours:'}"],
        [school_cache.start_time && school_cache.start_time ? "#{school_cache.start_time} - #{school_cache.end_time}" : 'n/a']
    ]

    table(data,
          :position => x_position,
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => BLACK}) do
      cells.borders = []
    end
  end

  def draw_best_known_for(school_cache, school, x_position)
    fill_color 100, 20, 20, 20
    text_box "#{school_cache.best_known_for.present? ? school_cache.best_known_for.truncate(79) : school_cache.best_known_for}",
             :at => [x_position, cursor],
             :width => school.which_icon.present? && school.which_icon != 'N/A' ? 95 : 135,
             :height => school.which_icon.present? && school.which_icon != 'N/A' ? 50 : 20,
             :size => FONT_SIZE_7,
             :style => :italic
  end

# second column

  def draw_second_column(school_cache, school)
    grid([0, 2], [2, 3]).bounding_box do
      draw_at_a_glance_table(school_cache)

      move_down_medium

      draw_application_table(school_cache, school)
    end
  end

  def draw_at_a_glance_table(school_cache)
    fill_color BLACK
    text_box is_spanish ? "Estadísticas de escuela" : "At a glance",
             :at => [0, cursor],
             :width => 100,
             :height => 10,
             :size => FONT_SIZE_8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color DARK_BLUE
      horizontal_line 0, COL_WIDTH, :at => cursor
    end

    move_down_small

    which_school_size = is_spanish ? 'Tamaño de la escuela' : 'School size'
    which_transportation = is_spanish ? 'Transporte' : 'Transportation'
    which_before_care = is_spanish ? 'Cuidado antes de clases' : 'Before care'
    which_after_care = is_spanish ? 'Cuidado despues de clases' : 'After care'
    which_uniform = is_spanish ? 'Vestimenta' : 'Uniform/Dress code'
    which_pre_k = is_spanish ? 'Preescolar' : 'PreK'

    data = [[{:image => IMAGE_PATH_SCHOOL_SIZE, :scale => IMAGE_SCALE_25}, which_school_size, school_cache.students_enrolled != "?" ? school_cache.students_enrolled : 'n/a'],
            [{:image => IMAGE_PATH_TRANSPORTATION, :scale => IMAGE_SCALE_25}, which_transportation, yes_si_no_mapping(school_cache.transportation)],
            [{:image => IMAGE_PATH_BEFORE_CARE, :scale => IMAGE_SCALE_25}, which_before_care, yes_si_no_mapping(school_cache.before_care)],
            [{:image => IMAGE_PATH_AFTER_CARE, :scale => IMAGE_SCALE_25}, which_after_care, yes_si_no_mapping(school_cache.after_school)],
            [{:image => IMAGE_PATH_UNIFORM, :scale => IMAGE_SCALE_25}, which_uniform, yes_si_no_mapping(school_cache.dress_code)],
            [{:image => IMAGE_PATH_PRE_K, :scale => IMAGE_SCALE_25}, which_pre_k, yes_si_no_mapping(school_cache.early_childhood_programs)]
    ]

    table(data, :column_widths => [30, 110, 30],
          :row_colors => [WHITE, GREY],
          :cell_style => {size: 8, :padding => [2, 5, 2, 5]}) do
      cells.borders = []
      columns(2).font_style = :bold
      column(2).align = :right

      cells.style(:height => 13)
    end
  end

  def yes_si_no_mapping(data)
    if is_spanish
      spanish_yes_map = {
          'Yes' => 'Sí',
          'No' => 'No'
      }
      data == "Yes" || data == "No" ? spanish_yes_map[data] : "n/a"
    else
      data == "Yes" || data == "No" ? data : "n/a"
    end
  end

  def draw_application_table(school_cache, school)
    fill_color GREY
    fill_rounded_rectangle([0, cursor], COL_WIDTH, 85, 5)

    move_down_small

    fill_color BLACK
    text_box is_spanish ? 'Aplicación' : "Application",
             :at => [5, cursor],
             :width => 75,
             :height => 10,
             :size => FONT_SIZE_8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color DARK_BLUE
      horizontal_line 5, COL_WIDTH - 5, :at => cursor
    end

    move_down_small

    deadline = is_spanish ? school.which_deadline_mapping : school_cache.deadline

    data = [
        [is_spanish ? 'Fecha limite' : 'Deadline', deadline],
        [is_spanish ? 'Costo de Matrícula' : 'Tuition', school_cache.tuition],
        [is_spanish ? 'Ayuda financiera' : 'Financial aid', yes_si_no_mapping(school_cache.aid)],
        [is_spanish ? 'Vales validos' : 'Voucher accepted', yes_si_no_mapping(school_cache.voucher)],
        [is_spanish ? 'Impuesto beca' : 'Tax scholarship', yes_si_no_mapping(school_cache.tax_scholarship)],
    ]

    table(data, :column_widths => [77, 93],
          :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
      cells.style(:height => 12)
    end
  end

# third column

  def draw_third_column(school_cache, school)
    grid([0, 4], [2, 5]).bounding_box do

      draw_diversity_table(school_cache, school)

      move_down_medium

      draw_grads_go_to_table(school_cache)

      move_down_small

      draw_ell_and_sped_table(school_cache, school)

      move_down_medium

      draw_programs_table(school_cache)

    end
  end

  def draw_diversity_table(school_cache, school)
    fill_color BLACK
    text_box is_spanish ? 'Diversidad' : 'Diversity',
             :at => [0, cursor],
             :width => 75,
             :height => 11,
             :size => FONT_SIZE_8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color DARK_BLUE
      horizontal_line 0, COL_WIDTH, :at => cursor
    end

    move_down_small

    ethnicity_data = school_cache.formatted_ethnicity_data.to_a

    if ethnicity_data != []
      if is_spanish
        data = school_cache.formatted_ethnicity_data
        ethnicity_data = school.which_ethnicity_key_mapping(data)
      else
        ethnicity_data
      end
    else
      if is_spanish
        ethnicity_data << ['No hay datos', ' ']
      else
        ethnicity_data << ['No diversity data available', ' ']
      end

    end

    if is_spanish
      ethnicity_data << ['Almuerzo gratis o precio reducido', school_cache.free_and_reduced_lunch != "?" ? school_cache.free_and_reduced_lunch : "n/a"]
    else
      ethnicity_data << ['Free and reduced lunch', school_cache.free_and_reduced_lunch != "?" ? school_cache.free_and_reduced_lunch : "n/a"]
    end
    table(ethnicity_data, :column_widths => [135, 35],
          :row_colors => [WHITE, GREY],
          :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
      cells.style(:height => 11)
    end
  end

  def draw_grads_go_to_table(school_cache)
    text_box is_spanish ? 'Estudiantes graduado asisten?' : 'Our grads typically go to:',
             :at => [0, cursor],
             # :width => 75,
             :width => COL_WIDTH,
             :height => 11,
             :size => FONT_SIZE_8,
             :style => :bold

    move_down_medium
    data = [
        [school_cache.destination_school_1 ? school_cache.destination_school_1.truncate(47) : "n/a"],
        [school_cache.destination_school_2 ? school_cache.destination_school_2.truncate(47) : " "],
        [school_cache.destination_school_3 ? school_cache.destination_school_3.truncate(47) : " "]

    ]

    table(data, :column_widths => [COL_WIDTH],
          :cell_style => {size: 7, :padding => [0, 0, 0, 0]}) do
      cells.borders = []
      cells.style(:height => 10)
    end
  end

  def draw_ell_and_sped_table(school_cache, school)
    which_ell = is_spanish ? 'Servicios ELL:' : 'ELL offering:'
    which_sped = is_spanish ? 'Educación Especial:' : 'SPED offering:'

    ell_rating = is_spanish ? school.which_ell_mapping : school_cache.ell
    sped_rating = is_spanish ? school.which_sped_mapping : school_cache.sped

    data = [
        [which_ell, which_sped],
        [ell_rating.nil? ? 'n/a' : ell_rating, sped_rating.nil? ? 'n/a' : sped_rating]
    ]

    table(data, :column_widths => [80, 80],
          :cell_style => {size: 8, :padding => [0, 0, 0, 0]}) do
      cells.borders = []
      cells.style(:height => 11)
      row(0).font_style = :bold
      row(0).size = 8

    end
  end

  def draw_programs_table(school_cache)
    text_box is_spanish ? 'Programas' : 'Programs',
             :at => [0, cursor],
             :width => 75,
             :height => 10,
             :size => FONT_SIZE_8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color DARK_BLUE
      horizontal_line 0, COL_WIDTH, :at => cursor
    end

    move_down_small

    data = [[school_cache.world_languages != NO_PROGRAM_DATA && school_cache.world_languages != 0 ? {:image => IMAGE_PATH_WORLD_LANGUAGES, :scale => 0.3} : " ",
             school_cache.clubs != NO_PROGRAM_DATA && school_cache.clubs != 0 ? {:image => IMAGE_PATH_CLUBS, :scale => 0.3} : " ",
             school_cache.sports != NO_PROGRAM_DATA && school_cache.sports !=0 ? {:image => IMAGE_PATH_SPORTS, :scale => 0.3} : " ",
             school_cache.arts_and_music != NO_PROGRAM_DATA && school_cache.arts_and_music != 0 ? {:image => IMAGE_PATH_VISUAL_ARTS, :scale => 0.3} : " "]
    ]

    table(data, :column_widths => [20, 20, 20, 20],
          :cell_style => {:padding => [0, 0, 0, 0]}) do
      cells.borders = []
      cells.style(:height => 16)
    end
  end

  def draw_location_index_columns_on_page(schools_decorated_with_cache_results)
    column_box([0, cursor], reflow_margins: true, :columns => 3, :width => bounds.width) do

      map_icon_to_school_name_mapping = find_schools_by_location_for_index(schools_decorated_with_cache_results)
      map_icon_to_school_name_mapping.sort.map do |key, value|
        draw_location_index_columns(value, key)
      end
    end
  end

  def draw_index_page_title(is_spanish, spanish_title, english_title)
    fill_color DARK_BLUE
    text_box is_spanish ? spanish_title : english_title,
             # :at => [5, cursor],
             :width => 545,
             :height => 25,
             :size => 24,
             :style => :bold,
             :align => :center
    # :align => :nil


    move_down 30
    stroke do
      stroke_color DARK_BLUE
      horizontal_line 5, 540, :at => cursor
    end
    move_down 25
  end

  def draw_performance_index_columns_on_page(is_spanish, schools_decorated_with_cache_results)
    column_box([0, cursor], reflow_margins: true, :columns => 3, :width => bounds.width) do

      above_avg_overall_rating = find_above_avg_schools_for_index(schools_decorated_with_cache_results, 'overall_gs_rating')
      draw_performance_index_columns(above_avg_overall_rating, is_spanish ? 'Por encima del promedio - calificación general' : 'Above average overall rating')
      above_avg_test_score_rating = find_above_avg_schools_for_index(schools_decorated_with_cache_results, 'test_score_rating')
      draw_performance_index_columns(above_avg_test_score_rating, is_spanish ? 'Por encima del promedio - calificación de examenes' : 'Above average test score rating')
      above_avg_growth_rating = find_above_avg_schools_for_index(schools_decorated_with_cache_results, 'student_growth_rating')
      draw_performance_index_columns(above_avg_growth_rating, is_spanish ? 'Por encima del promedio - calificación de crecimiento' : 'Above average growth rating')
      above_avg_college_readiness = find_above_avg_schools_for_index(schools_decorated_with_cache_results, 'college_readiness_rating')
      draw_performance_index_columns(above_avg_college_readiness, is_spanish ? 'Por encima del promedio - calificación universitaria' : 'Above average college readiness rating')
    end
  end

  def draw_performance_index_columns(above_avg_schools, rating_name)

    which_ratings_index(above_avg_schools, rating_name)
    move_down_medium
  end

  def draw_location_index_columns(school_names, map_icon_name)
    which_map_icon_index(school_names, map_icon_name)
    move_down_medium
  end

  def which_map_icon_index(school_names, map_icon_name)

    if school_names.any?
      if map_icon_name == 'no_map_icon'
        fill_color DARK_BLUE
        text is_spanish ? 'No está en la región del mapa' : 'Not in region map', :size => 12
      else
        map_icon_image_path = 'app/assets/images/pyoc/map_icons/'
        image  map_icon_image_path + map_icon_name, :scale => 0.2
        move_down_small
      end
      fill_color DARK_GREY
      school_names.each do |string|
        text string, :size => FONT_SIZE_8
      end
    end
  end

  def which_ratings_index(school_names, rating_name)
    if school_names.any?
      fill_color DARK_BLUE
      text rating_name, :size => 12
      fill_color DARK_GREY
      school_names.each do |string|
        text string, :size => FONT_SIZE_8
      end
    end
  end


end