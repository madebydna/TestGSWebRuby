class PyocPdf < Prawn::Document

  $rect_edge_rounding = 10
  $blue_line = 70, 15, 0, 0
  $white = 0, 0, 0, 0
  $grey = 0, 0, 0, 6
  $black = 0, 0, 0, 100
  $school_profile_blue = 5, 1, 0, 0
  $col_width = 160
  $start_page_number = 5
  $position_on_page = 0
  $start_page_number = 5

  $image_path_school_size= "app/assets/images/pyoc/school_size_pyoc.png"
  $image_path_transportation= "app/assets/images/pyoc/transportation_pyoc.png"
  $image_path_before_care= "app/assets/images/pyoc/before_care_pyoc.png"
  $image_path_after_care= "app/assets/images/pyoc/after_care_pyoc.png"
  $image_path_uniform= "app/assets/images/pyoc/uniform_pyoc.png"
  $image_path_pre_k= "app/assets/images/pyoc/pre_k_pyoc.png"

  $image_path_world_languages = "app/assets/images/pyoc/world_languages.png"
  $image_path_clubs = "app/assets/images/pyoc/clubs.png"
  $image_path_sports = "app/assets/images/pyoc/sports.png"
  $image_path_visual_arts = "app/assets/images/pyoc/visual_arts.png"
  $no_program_data = "?"

  def initialize(schools_decorated_with_cache_results)

    beginning = Time.now
    super()

# todo make $col_width and col_height relational to gutter

    define_grid(:columns => 6, :rows => 9, :gutter => 20)
    
    schools_decorated_with_cache_results.each_with_index  do |school, index|

      if index % 3 == 0 and index != 0
        start_new_page(:size => "LETTER")
        $position_on_page = 0
      end

      if index % 3 != 0
        $position_on_page += 3
      end

      # todo delete this when done
      puts school.id

      draw_header(school)

      school_cache = school.school_cache

      grid([$position_on_page, 0], [$position_on_page+2, 5]).bounding_box do
        move_down 18
        draw_first_column(school, school_cache)
        #     grid([1,2],[3,3]).show
        draw_second_column(school_cache)
#       grid([0, 4], [2, 5]).show
        draw_third_column(school_cache)

        move_down_medium
        draw_grey_line(index)
      end

      draw_footer
      index += 1

    end
    puts "Time elapsed #{Time.now - beginning} seconds"
  end

  def move_down_small
    move_down 5
  end

  def move_down_medium
    move_down 10
  end
  
  def draw_header(school)
    if school.is_high_school
      fill_color $blue_line
      text_box "GRADES 9-12",
               :at => [250, 735],
               :width => $col_width,
               :height => 20,
               :size => 9
      # :style => :bold
      stroke do
        stroke_color $blue_line
        horizontal_line 0, 535, :at => 725
      end
    elsif school.is_k8
      fill_color $grey
      text_box "GRADES PK-8",
               :at => [250, 735],
               :width => $col_width,
               :height => 20,
               :size => 9
      # :style => :bold
      stroke do
        stroke_color $grey
        horizontal_line 0, 535, :at => 725
      end
    end
    
  end

  def draw_footer
    image 'app/assets/images/pyoc/GS_logo-21.png', :at => [180, -10], :scale => 0.2
    number_pages '<page>', {:at => [270, -15], :size => 7, :start_count_at => $start_page_number}
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
        stroke_color $grey
        horizontal_line 0, 535, :at => cursor
      end
    end
  end

# first column

  def draw_first_column(school, school_cache)
    grid([0, 0], [2, 1]).bounding_box do
      # blue rectangle
      fill_color $school_profile_blue
      fill_rounded_rectangle([0, cursor], $col_width, 225, $rect_edge_rounding)
      fill_color 100, 20, 20, 20
      move_down_small

      draw_name_grade_type_and_district(school, school_cache)

      move_down 15

      draw_overall_gs_rating(school_cache)
      draw_other_gs_ratings_table(school_cache)

      move_down_medium

      stroke do
        stroke_color $grey
        horizontal_line 5, ($col_width - 5), :at => cursor
      end

      move_down_small

      other_state_ratings(school_cache)

      bounding_box([1, 100], :width => 0, :height => 0) do
        move_down_medium
        if $position_on_page%2 == 0
          image "app/assets/images/pyoc/PYOC_Icons-03.png", :at => [5, cursor], :scale => 0.2
        else
          image "app/assets/images/pyoc/PYOC_Icons-04.png", :at => [5, cursor], :scale => 0.2
        end
      end

      move_down_small
      draw_address(school, school_cache)

      move_down_medium
      draw_best_known_for(school_cache)

    end
  end

  def draw_name_grade_type_and_district(school, school_cache)
    text_box school.name,
             #
             :at => [5, cursor],
             :width => $col_width - 5,
             :height => 40,
             :size => 10,
             :style => :bold

    move_down 40
    fill_color $black
    text_box " #{school.process_level} | #{school.decorated_school_type} #{school.district != nil ? ' | '+ school.district.name.truncate(32) : ' ' }",
             :at => [5, cursor],
             :width => $col_width,
             :height => 20,
             :size => 6

  end

  def draw_gs_rating_image(rating)
    gs_overall_rating_image = 'nr'
    if '1,2,3,4,5,6,7,8,9,10'.include? rating
      gs_overall_rating_image = rating
    end
    image "app/assets/images/pyoc/overall_rating_#{gs_overall_rating_image}.png", :at => [15, cursor], :scale => 0.25
  end

  def draw_overall_gs_rating(school_cache)
    bounding_box([1, cursor], :width => 0, :height => 0) do
      move_down 2

      draw_gs_rating_image(school_cache.overall_gs_rating)

      move_down 25
      fill_color $black
      text_box "Overall rating",
               :at => [17, cursor],
               :width => 25,
               :height => 25,
               :size => 6,
               :style => :bold

    end
  end

  def draw_other_gs_ratings_table(school_cache)
    data = [
        ['Test score rating', school_cache.test_scores_rating],
        ['Student growth rating', school_cache.student_growth_rating],
        ['College readiness', school_cache.college_readiness_rating],
    ]
    table(data, :column_widths => [80, 10],
          :position => 55,
          :cell_style => {size: 7, :height => 12, :padding => [0, 0, 1, 0], :text_color => $black}) do
      cells.borders = []
      columns(1).font_style = :bold
    end
  end

  def other_state_ratings(school_cache)
    data =[[], []]

    other_ratings = school_cache.formatted_non_greatschools_ratings.to_a
    if other_ratings == []
      data << ['', '']
    else
      other_ratings.each do |i|
        data[0] << i[1]
        data[1] << i[0]
      end
    end

    table(data, :column_widths => [53, 53, 53],
          :position => 5,
          :cell_style => {size: 6, :padding => [0, 0, 0, 0], :text_color => $black}) do
      cells.borders = []
      row(0).font_style = :bold
      row(0).size = 7
      row(0).padding = [0, 0, 5, 10]
    end
  end

  def draw_address(school, school_cache)
    data =[[school.street],
           ["#{school.city}, #{school.state} #{school.zipcode}"],
           ["Phone: #{school.phone}"],
           [' '],
           ['School Hours:'],
           [school_cache.start_time && school_cache.start_time ? "#{school_cache.start_time} - #{school_cache.end_time}" : 'n/a']
    ]
    table(data,
          :position => 60,
          :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => $black}) do
      cells.borders = []
    end
  end

  def draw_best_known_for(school_cache)
    fill_color 100, 20, 20, 20
    text_box "#{school_cache.best_known_for}",
             :at => [5, cursor],
             :width => 155,
             :height => 30,
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
    fill_color $black
    text_box "At a glance",
             :at => [0, cursor],
             :width => 75,
             :height => 10,
             :size => 8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color $blue_line
      horizontal_line 0, $col_width, :at => cursor
    end

    move_down_small

    data = [[{:image => $image_path_school_size, :scale => 0.25}, 'School size', school_cache.students_enrolled != "?" ? school_cache.students_enrolled : 'n/a' ],
            # data = [[{:image => image_path, :scale => 0.2}, 'School size', "123"],
            [{:image => $image_path_transportation, :scale => 0.25}, 'Transportation',
             school_cache.transportation == "Yes" || school_cache.transportation == "No" ? school_cache.transportation : "n/a"],
            [{:image => $image_path_before_care, :scale => 0.25}, 'Before care',
             school_cache.before_care == "Yes" || school_cache.before_care == "No" ? school_cache.before_care : "n/a"],
            [{:image => $image_path_after_care, :scale => 0.25}, 'After care',
             school_cache.after_school == "Yes" || school_cache.after_school == "No" ? school_cache.after_school : "n/a"],
            [{:image => $image_path_uniform, :scale => 0.25}, 'Uniform/Dress code', school_cache.dress_code],
            [{:image => $image_path_pre_k, :scale => 0.25}, 'Pre K', school_cache.early_childhood_programs]
    ]

    table(data, :column_widths => [30, 100, 30],
          :row_colors => [$white, $grey],
          :cell_style => {size: 8, :padding => [2, 5, 2, 5]}) do
      cells.borders = []
      columns(2).font_style = :bold
      column(2).align = :right

      cells.style(:height => 13)
    end
  end

  def draw_application_table(school_cache)
    fill_color $grey
    fill_rounded_rectangle([0, cursor], $col_width, 85, 5)

    move_down_small

    fill_color $black
    text_box "Application",
             :at => [5, cursor],
             :width => 75,
             :height => 10,
             :size => 8,
             :style => :bold

    move_down_medium
    stroke do
      stroke_color $blue_line
      horizontal_line 5, $col_width - 5, :at => cursor
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
    fill_color $black
    text_box "Diversity",
             :at => [0, cursor],
             :width => 75,
             :height => 11,
             :size => 8,
             :style => :bold
    move_down_medium
    stroke do
      stroke_color $blue_line
      horizontal_line 0, $col_width, :at => cursor
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
          :row_colors => [$white, $grey],
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

    table(data, :column_widths => [$col_width],
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
      stroke_color $blue_line
      horizontal_line 0, $col_width, :at => cursor
    end

    move_down_small

    data = [[school_cache.world_languages != $no_program_data ? {:image => $image_path_world_languages, :scale => 0.3} : " ",
             school_cache.clubs != $no_program_data ? {:image => $image_path_clubs, :scale => 0.3} : " ",
             school_cache.sports != $no_program_data ? {:image => $image_path_sports, :scale => 0.3} : " ",
             school_cache.arts_and_music != $no_program_data ? {:image => $image_path_visual_arts, :scale => 0.3} : " "]
    ]

    table(data, :column_widths => [20, 20, 20, 20],
          :cell_style => {:padding => [0, 0, 0, 0]}) do
      cells.borders = []
      cells.style(:height => 16)
    end
  end


end

