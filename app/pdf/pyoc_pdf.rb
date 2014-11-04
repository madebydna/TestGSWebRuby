#encoding: utf-8
class PyocPdf < Prawn::Document


  Rect_edge_rounding = 10
  Dark_blue = 70, 15, 0, 0
  White = 0, 0, 0, 0
  Grey = 0, 0, 0, 6
  Black = 0, 0, 0, 100
  Dark_grey = 0, 0, 0, 51
  Light_blue = 5, 1, 0, 0
  Col_width = 170

  Image_path_school_size= "app/assets/images/pyoc/school_size_pyoc.png"
  Image_path_transportation= "app/assets/images/pyoc/transportation_pyoc.png"
  Image_path_before_care= "app/assets/images/pyoc/before_care_pyoc.png"
  Image_path_after_care= "app/assets/images/pyoc/after_care_pyoc.png"
  Image_path_uniform= "app/assets/images/pyoc/uniform_pyoc.png"
  Image_path_pre_k= "app/assets/images/pyoc/pre_k_pyoc.png"

  Image_path_world_languages = "app/assets/images/pyoc/world_languages.png"
  Image_path_clubs = "app/assets/images/pyoc/clubs.png"
  Image_path_sports = "app/assets/images/pyoc/sports.png"
  Image_path_visual_arts = "app/assets/images/pyoc/visual_arts.png"
  No_program_data = "?"

  def initialize(schools_decorated_with_cache_results,is_k8_batch,is_high_school_batch,is_pk8_batch,get_page_number_start,is_spanish)
    @is_spanish=is_spanish
    start_time = Time.now
    super()

# todo make Col_width and col_height relational to gutter

    define_grid(:columns => 6, :rows => 9, :gutter => 15)

    # grid.show_all

    position_on_page = 0

    schools_decorated_with_cache_results.each_with_index  do |school, index|

      if index % 3 == 0 and index != 0
        start_new_page(:size => "LETTER")
        position_on_page = 0
      end

      if index % 3 != 0
        position_on_page += 3
      end

      puts "#{self.class} - Generating PYOC PDF for School ID - #{school.id} ,State #{school.state} "

      draw_header(is_k8_batch,is_high_school_batch,is_pk8_batch)

      school_cache = school.school_cache

      grid([position_on_page, 0], [position_on_page+2, 5]).bounding_box do
        move_down 18
        draw_first_column(school, school_cache, is_high_school_batch, is_k8_batch,is_pk8_batch)
        draw_second_column(school_cache, school)
        draw_third_column(school_cache, school)

        move_down_small
        draw_grey_line(index)
      end


      draw_footer(get_page_number_start)
    end
    end_time =Time.now - start_time

    puts  "#{self.class} - Time taken to generate the PDF #{end_time}seconds"
    # above_avg = []
    # avg = []
    # below_avg = []
    #
    # above_avg_ratings = '8, 9, 10'
    # avg_ratings = '7, 6, 5, 4'
    # below_avg_ratings = '3, 2, 1'
    # schools_decorated_with_cache_results.each do |school|
    #   school_cache = school
    #   if above_avg_ratings.include? school.school_cache.overall_gs_rating
    #     above_avg.push(school_cache.name)
    #   end
    #   if avg_ratings.include? school.school_cache.overall_gs_rating
    #     avg.push(school_cache.name)
    #     end
    #   if below_avg_ratings.include? school.school_cache.overall_gs_rating
    #     below_avg.push(school_cache.name)
    #   end
    # end

    # draw_index_columns(above_avg, avg, below_avg)
    # draw_map_icons_index_columns(school.zipcode)
  end

  def draw_index_columns(above_avg, avg ,below_avg)

    start_new_page(:size => "LETTER") #todo: don't need this once index is moved to own controller
    fill_color Dark_blue
    text_box 'SCHOOLS BY PERFORMANCE',
             :at => [Col_width/2, cursor],
             :height => 25,
             :size => 24,
             :style => :bold

    move_down 30
    stroke do
      stroke_color Dark_blue
      horizontal_line 5, 540, :at => cursor
    end

    move_down 25

    column_box([0, cursor], :columns => 3, :width => bounds.width) do

      which_ratings_index(above_avg, 'Above average')
      move_down_small
      which_ratings_index(avg, 'Average')
      move_down_small
      which_ratings_index(below_avg, 'Below average')
    end
  end

  def which_ratings_index(array, rating_name)
    if array.any?
      fill_color Dark_blue
      text rating_name , :size => 14
      fill_color Dark_grey
      array.each do |string|
        text string, :size => 8
      end
    end
  end

  # def draw_map_icons_index_columns(school_cache.zipcode)
  #   puts school.which_icon(school_cache.zipcode)

  # end

  def move_down_small
    move_down 5
  end

  def move_down_medium
    move_down 10
  end

  def draw_header(is_k8_batch,is_high_school_batch,is_pk8_batch)

    grade = is_spanish ? 'GRADO' : 'GRADE'

    if is_high_school_batch
      fill_color Dark_blue
      text_box grade + " 9-12",
               :at => [250, 735],
               :width => Col_width,
               :height => 20,
               :size => 9
      stroke do
        stroke_color Dark_blue
        horizontal_line 0, 540, :at => 725
      end
    elsif is_pk8_batch
      fill_color Dark_grey
      text_box grade + " PK-8",
               :at => [250, 735],
               :width => Col_width,
               :height => 20,
               :size => 9
      stroke do
        stroke_color Dark_grey
        horizontal_line 0, 540, :at => 725
      end
    elsif is_k8_batch
    fill_color Dark_grey
    text_box grade + " K-8",
             :at => [250, 735],
             :width => Col_width,
             :height => 20,
             :size => 9
    stroke do
      stroke_color Dark_grey
      horizontal_line 0, 540, :at => 725
    end
  end

  end

  def draw_footer(get_page_number_start)
    image 'app/assets/images/pyoc/GS_logo-21.png', :at => [180, -10], :scale => 0.2
    number_pages '<page>', {:at => [270, -15], :size => 7, :start_count_at => get_page_number_start}
    text_box 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
             :at => [300, -15],
             :width => 200,
             :height => 10,
             :size => 7,
             :style => :italic
  end

  def draw_grey_line(index)
    if index % 3 != 2
      stroke do
        stroke_color Grey
        horizontal_line 0, 540, :at => cursor
      end
    end
  end

# first column

  def draw_first_column(school, school_cache, is_high_school_batch, is_k8_batch,is_pk8_batch)
    grid([0, 0], [2, 1]).bounding_box do
      # blue rectangle
      if is_high_school_batch
        fill_color Light_blue
      elsif is_k8_batch || is_pk8_batch
        fill_color Grey
      end
      fill_rounded_rectangle([0, cursor], Col_width, 225, Rect_edge_rounding)
      fill_color 100, 20, 20, 20
      move_down_small

      draw_name_grade_type_and_district(school, school_cache)

      move_down 15

      draw_overall_gs_rating(school_cache)
      draw_other_gs_ratings_table(school_cache)

      move_down_medium

      stroke do
        stroke_color Grey
        horizontal_line 5, (Col_width - 5), :at => cursor
      end

      move_down_small

      other_state_ratings(school_cache, school)

      move_down 15
      draw_address(school)

      map_icon = draw_map_icon(school)
      if map_icon != 'N/A'
        bounding_box([1, 70], :width => 0, :height => 0) do
          move_down_medium

          image map_icon, :at => [15, cursor], :scale => 0.2
        end

        move_down 15

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
             :width => Col_width - 10,
             :height => 40,
             :size => 10,
             :style => :bold

    move_down 40
    fill_color Black

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
    # if school.district != nil
    #   if level.include? '& UG'
    #     truncated_district = '| ' + truncate_district(school, 27)
    #   else
    #     truncated_district = '| ' + truncate_district(school, 36)
    #   end
    # else
    #   truncated_district = ' '
    # end
    truncated_district = ' '
   school_type = school.which_school_type

    text_box "#{level} | #{is_spanish ? school_type : school.decorated_school_type} #{truncated_district}",
             :at => [5, cursor],
             :width => Col_width - 10,
             :height => 20,
             :size => 6
  end

  def draw_gs_rating_image(rating)
    image "app/assets/images/pyoc/overall_rating_#{rating}.png", :at => [15, cursor], :scale => 0.25
  end
  def is_spanish
    @is_spanish == true
  end

  def draw_overall_gs_rating(school_cache)
    bounding_box([1, cursor], :width => 0, :height => 0) do
      move_down 2

      draw_gs_rating_image(school_cache.overall_gs_rating)

      move_down 25
      fill_color Black
      text_box is_spanish ? "Calificación general" : "Overall rating",
               :at => [ is_spanish ? 10 : 17, cursor],
               :width => is_spanish ? 35 : 25,
               :height => 25,
               :size => 6,
               :style => :bold

    end
  end

  def draw_other_gs_ratings_table(school_cache)
    data = get_gs_rating_info(school_cache)
    table(data, :column_widths => [80, 10],
          :position => 55,
          :cell_style => {size: 7, :height => 12, :padding => [0, 0, 1, 0], :text_color => Black}) do
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
    rating_abbr = { 'Excellent Schools Detroit Rating' => 'ESD Rating',
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
            data[0] << i[1]
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
          :cell_style => {size: 6, :padding => [0, 0, 0, 0], :text_color => Black}) do
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
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => Black}) do
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
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => Black}) do
      cells.borders = []
    end
  end

  def draw_best_known_for(school_cache, school, x_position)
    fill_color 100, 20, 20, 20
    text_box "#{school_cache.best_known_for.present? ? school_cache.best_known_for.truncate(79) : school_cache.best_known_for}",
             :at => [x_position, cursor],
             :width => school.which_icon.present? && school.which_icon != 'N/A'?  95 : 135,
             :height => school.which_icon.present? && school.which_icon != 'N/A' ? 50 : 20,
             :size => 7,
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
    fill_color Black
    text_box is_spanish ? "Estadísticas de escuela" : "At a glance",
             :at => [0, cursor],
             :width => 100,
             :height => 10,
             :size => 8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color Dark_blue
      horizontal_line 0, Col_width, :at => cursor
    end

    move_down_small

    which_school_size = is_spanish ? 'Tamaño de la escuela' : 'School size'
    which_transportation = is_spanish ? 'Transporte' : 'Transportation'
    which_before_care = is_spanish ? 'Cuidado antes de clases' : 'Before care'
    which_after_care = is_spanish ? 'Cuidado despues de clases' : 'After care'
    which_uniform = is_spanish ? 'Vestimenta' : 'Uniform/Dress code'
    which_pre_k = is_spanish ? 'Preescolar' : 'Pre K'

    data = [[{:image => Image_path_school_size, :scale => 0.25}, which_school_size, school_cache.students_enrolled != "?" ? school_cache.students_enrolled : 'n/a' ],
            [{:image => Image_path_transportation, :scale => 0.25}, which_transportation, yes_si_no_mapping(school_cache.transportation )],
            [{:image => Image_path_before_care, :scale => 0.25}, which_before_care, yes_si_no_mapping(school_cache.before_care)],
            [{:image => Image_path_after_care, :scale => 0.25}, which_after_care, yes_si_no_mapping(school_cache.after_school)],
            [{:image => Image_path_uniform, :scale => 0.25}, which_uniform, yes_si_no_mapping(school_cache.dress_code)],
            [{:image => Image_path_pre_k, :scale => 0.25}, which_pre_k , yes_si_no_mapping(school_cache.early_childhood_programs)]
    ]

    table(data, :column_widths => [30, 110, 30],
          :row_colors => [White, Grey],
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
    fill_color Grey
    fill_rounded_rectangle([0, cursor], Col_width, 85, 5)

    move_down_small

    fill_color Black
    text_box @is_spanish == true ? 'Aplicación' : "Application",
             :at => [5, cursor],
             :width => 75,
             :height => 10,
             :size => 8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color Dark_blue
      horizontal_line 5, Col_width - 5, :at => cursor
    end

    move_down_small

    if school_cache.deadline != 'n/a'
      deadline = is_spanish ? school.which_deadline_mapping : school_cache.deadline
    else
      deadline = 'n/a'
    end

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
    fill_color Black
    text_box @is_spanish == true ? 'Diversidad' : 'Diversity',
             :at => [0, cursor],
             :width => 75,
             :height => 11,
             :size => 8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color Dark_blue
      horizontal_line 0, Col_width, :at => cursor
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
          :row_colors => [White, Grey],
          :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
      cells.style(:height => 11)
    end
  end

  def draw_grads_go_to_table(school_cache)
    text_box is_spanish ? 'Estudiantes graduado asisten?' : 'Our grads go to?',
             :at => [0, cursor],
             # :width => 75,
             :width => Col_width,
             :height => 11,
             :size => 8,
             :style => :bold

    move_down_medium
    data = [
        [school_cache.destination_school_1 ? school_cache.destination_school_1.truncate(47) : "n/a"],
        [school_cache.destination_school_2 ? school_cache.destination_school_2.truncate(47) : " "],
        [school_cache.destination_school_3 ? school_cache.destination_school_3.truncate(47) : " "]

    ]

    table(data, :column_widths => [Col_width],
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
        [ which_ell, which_sped],
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
             :size => 8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color Dark_blue
      horizontal_line 0, Col_width, :at => cursor
    end

    move_down_small

    data = [[school_cache.world_languages != No_program_data && school_cache.world_languages != 0 ? {:image => Image_path_world_languages, :scale => 0.3} : " ",
             school_cache.clubs != No_program_data && school_cache.clubs != 0 ? {:image => Image_path_clubs, :scale => 0.3} : " ",
             school_cache.sports != No_program_data &&  school_cache.sports !=0 ? {:image => Image_path_sports, :scale => 0.3} : " ",
             school_cache.arts_and_music != No_program_data  && school_cache.arts_and_music != 0 ? {:image => Image_path_visual_arts, :scale => 0.3} : " "]
    ]

    table(data, :column_widths => [20, 20, 20, 20],
          :cell_style => {:padding => [0, 0, 0, 0]}) do
      cells.borders = []
      cells.style(:height => 16)
    end
  end


end
