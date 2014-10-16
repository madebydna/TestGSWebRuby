# coding: utf-8

class PyocPdf < Prawn::Document


  Rect_edge_rounding = 10
  Blue_line = 70, 15, 0, 0
  White = 0, 0, 0, 0
  Grey = 0, 0, 0, 6
  Black = 0, 0, 0, 100
  School_profile_blue = 5, 1, 0, 0
  Col_width = 160

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

  def initialize(schools_decorated_with_cache_results,is_k8_batch,is_high_school_batch,get_page_number_start)

    start_time = Time.now
    super()

# todo make Col_width and col_height relational to gutter

    define_grid(:columns => 6, :rows => 9, :gutter => 20)

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

      draw_header(is_k8_batch,is_high_school_batch)

      school_cache = school.school_cache

      grid([position_on_page, 0], [position_on_page+2, 5]).bounding_box do
        move_down 18
        draw_first_column(school, school_cache)
        draw_second_column(school_cache)
        draw_third_column(school_cache)

        move_down_medium
        draw_grey_line(index)
      end

      draw_footer(get_page_number_start)
    end
    end_time =Time.now - start_time

    puts  "#{self.class} - Time taken to generate the PDF #{end_time}seconds"

  end

  def move_down_small
    move_down 5
  end

  def move_down_medium
    move_down 10
  end

  def draw_header(is_k8_batch,is_high_school_batch)
    if is_high_school_batch
      fill_color Blue_line
      text_box "GRADES 9-12",
               :at => [250, 735],
               :width => Col_width,
               :height => 20,
               :size => 9
      # :style => :bold
      stroke do
        stroke_color Blue_line
        horizontal_line 0, 535, :at => 725
      end
    elsif is_k8_batch
      fill_color Grey
      text_box "GRADES PK-8",
               :at => [250, 735],
               :width => Col_width,
               :height => 20,
               :size => 9
      # :style => :bold
      stroke do
        stroke_color Grey
        horizontal_line 0, 535, :at => 725
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
        horizontal_line 0, 535, :at => cursor
      end
    end
  end

# first column

  def draw_first_column(school, school_cache)
    grid([0, 0], [2, 1]).bounding_box do
      # blue rectangle
      fill_color School_profile_blue
      fill_rounded_rectangle([0, cursor], Col_width, 225, Rect_edge_rounding)
      fill_color 100, 20, 20, 20
      move_down_small

      draw_name_grade_type_and_district(school, school_cache)

      move_down 15

      draw_overall_gs_rating(school_cache)
      draw_other_gs_ratings_table(school_cache, spanish = false)

      move_down_medium

      stroke do
        stroke_color Grey
        horizontal_line 5, (Col_width - 5), :at => cursor
      end

      move_down_small

      other_state_ratings(school_cache)

      move_down 15
      draw_address(school)

      map_icon = draw_map_icon(school)
      if map_icon != 'N/A'
        bounding_box([1, 70], :width => 0, :height => 0) do
          move_down 15

          image map_icon, :at => [15, cursor], :scale => 0.2
        end

        move_down 15

        draw_school_hours(school_cache, 60)


        move_down_small
        draw_best_known_for(school_cache, 60)

      else
        move_down_small
        draw_school_hours(school_cache, 15)

        move_down_small
        draw_best_known_for(school_cache, 15)
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
    if school.district != nil
      level.include? '& UG' ? truncated_district = ' | ' + truncate_district(school, 25) : truncated_district =  ' | '+ truncate_district(school, 32)
    else
      truncated_district = ' '
    end

    text_box "#{level} | #{school.decorated_school_type} #{truncated_district}",
             :at => [5, cursor],
             :width => Col_width - 10,
             :height => 20,
             :size => 6
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

  def draw_gs_rating_image(rating)
    image "app/assets/images/pyoc/overall_rating_#{rating}.png", :at => [15, cursor], :scale => 0.25
  end

  def draw_overall_gs_rating(school_cache)
    bounding_box([1, cursor], :width => 0, :height => 0) do
      move_down 2

      draw_gs_rating_image(school_cache.overall_gs_rating)

      move_down 25
      fill_color Black
      text_box "Overall rating",
               :at => [17, cursor],
               :width => 25,
               :height => 25,
               :size => 6,
               :style => :bold

    end
  end

  def draw_other_gs_ratings_table(school_cache, spanish)
    data = get_gs_rating_info(school_cache, spanish)
    table(data, :column_widths => [80, 10],
          :position => 55,
          :cell_style => {size: 7, :height => 12, :padding => [0, 0, 1, 0], :text_color => Black}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
    end
  end

  def get_gs_rating_info(school_cache, spanish)
    if spanish
      data = [
          ['Puntuación de examenes', school_cache.test_scores_rating],
          ['Crecimiento', school_cache.student_growth_rating],
          ['Preparacion universitaria', school_cache.college_readiness_rating],
      ]

    else
      data = [
          ['Test score rating', school_cache.test_scores_rating],
          ['Student growth rating', school_cache.student_growth_rating],
          ['College readiness', school_cache.college_readiness_rating],
      ]
    end
    data
  end

  def other_state_rating_abbreviation(rating_name)
    rating_abbr = { 'Excellent Schools Detroit Rating' => 'ESD Rating',
                    'Great Start to Quality preschool rating' => 'Preschool Rating'
                  }
    rating_abbr[rating_name]
   end

  def other_state_ratings(school_cache)
    data =[[], []]

    other_ratings = school_cache.formatted_non_greatschools_ratings.to_a
    if other_ratings == []
      data << ['', '']
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

    table(data, :column_widths => [51, 51, 51],
          :position => 5,
          :cell_style => {size: 6, :padding => [0, 0, 0, 0], :text_color => Black}) do
      cells.borders = []
      row(0).font_style = :bold
      row(0).size = 7
      row(0).padding = [0, 0, 5, 10]
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
           ["Phone: #{school.phone}"],
    ]


    table(data,
          :position => 15,
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => Black}) do
      cells.borders = []
    end

  end

  def draw_school_hours(school_cache, x_position)
    data = [
        ['School Hours:'],
        [school_cache.start_time && school_cache.start_time ? "#{school_cache.start_time} - #{school_cache.end_time}" : 'n/a']
    ]

    table(data,
          :position => x_position,
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => Black}) do
      cells.borders = []
    end
  end

  def draw_best_known_for(school_cache, x_position)
    fill_color 100, 20, 20, 20
    text_box "#{school_cache.best_known_for}",
             :at => [x_position, cursor],
             :width => 95,
             :height => 50,
             :size => 7,
             :style => :italic
  end

# second column

  def draw_second_column(school_cache)
    grid([0, 2], [2, 3]).bounding_box do
      draw_at_a_glance_table(school_cache)

      move_down_medium

      draw_application_table(school_cache)
    end
  end

  def draw_at_a_glance_table(school_cache)
    fill_color Black
    text_box "At a glance",
             :at => [0, cursor],
             :width => 75,
             :height => 10,
             :size => 8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color Blue_line
      horizontal_line 0, Col_width, :at => cursor
    end

    move_down_small

    data = [[{:image => Image_path_school_size, :scale => 0.25}, 'School size', school_cache.students_enrolled != "?" ? school_cache.students_enrolled : 'n/a' ],
            [{:image => Image_path_transportation, :scale => 0.25}, 'Transportation',
             school_cache.transportation == "Yes" || school_cache.transportation == "No" ? school_cache.transportation : "n/a"],
            [{:image => Image_path_before_care, :scale => 0.25}, 'Before care',
             school_cache.before_care == "Yes" || school_cache.before_care == "No" ? school_cache.before_care : "n/a"],
            [{:image => Image_path_after_care, :scale => 0.25}, 'After care',
             school_cache.after_school == "Yes" || school_cache.after_school == "No" ? school_cache.after_school : "n/a"],
            [{:image => Image_path_uniform, :scale => 0.25}, 'Uniform/Dress code', school_cache.dress_code],
            [{:image => Image_path_pre_k, :scale => 0.25}, 'Pre K', school_cache.early_childhood_programs]
    ]

    table(data, :column_widths => [30, 100, 30],
          :row_colors => [White, Grey],
          :cell_style => {size: 8, :padding => [2, 5, 2, 5]}) do
      cells.borders = []
      columns(2).font_style = :bold
      column(2).align = :right

      cells.style(:height => 13)
    end
  end

  def draw_application_table(school_cache)
    fill_color Grey
    fill_rounded_rectangle([0, cursor], Col_width, 85, 5)

    move_down_small

    fill_color Black
    text_box "Application",
             :at => [5, cursor],
             :width => 75,
             :height => 10,
             :size => 8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color Blue_line
      horizontal_line 5, Col_width - 5, :at => cursor
    end

    move_down_small
    data = [
        ['Deadlines', school_cache.deadline],
        ['Tuition', school_cache.tuition],
        ['Financial aid', school_cache.aid],
        ['Voucher accepted', school_cache.voucher],
        ['Tax scholarship', school_cache.tax_scholarship],
    ]

    table(data, :column_widths => [90, 70],
          :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
      cells.style(:height => 12)
    end
  end

# third column

  def draw_third_column(school_cache)
    grid([0, 4], [2, 5]).bounding_box do

      draw_diversity_table(school_cache)

      move_down_medium

      draw_grads_go_to_table(school_cache)

      move_down_small

      draw_ell_and_sped_table(school_cache)

      move_down_medium

      draw_programs_table(school_cache)

    end
  end

  def draw_diversity_table(school_cache)
    fill_color Black
    text_box "Diversity",
             :at => [0, cursor],
             :width => 75,
             :height => 11,
             :size => 8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color Blue_line
      horizontal_line 0, Col_width, :at => cursor
    end

    move_down_small

    ethnicity_data = school_cache.formatted_ethnicity_data.to_a

    if ethnicity_data != []
      ethnicity_data
    else
      ethnicity_data << ['No diversity data available', ' ']
    end
    ethnicity_data << ['Free and reduced lunch', school_cache.free_and_reduced_lunch != "?" ? school_cache.free_and_reduced_lunch : "n/a"]

    table(ethnicity_data, :column_widths => [130, 30],
          :row_colors => [White, Grey],
          :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
      cells.borders = []
      columns(1).font_style = :bold
      column(1).align = :right
      cells.style(:height => 11)
    end
  end

  def draw_grads_go_to_table(school_cache)
    text_box 'Our grads go to?',
             :at => [0, cursor],
             :width => 75,
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

  def draw_ell_and_sped_table(school_cache)
    data = [
        ['ELL offering:', 'SPED offering:'],
        [school_cache.ell, school_cache.sped]
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
    text_box 'Programs',
             :at => [0, cursor],
             :width => 75,
             :height => 10,
             :size => 8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color Blue_line
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
