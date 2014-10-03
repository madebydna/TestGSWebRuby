class PyocPdf < Prawn::Document
  def initialize(schools_decorated_with_cache_results)

    beginning = Time.now
    super()

    rect_edge_rounding = 10
    blue_line = 70, 15, 0, 0
    white = 0, 0, 0, 0
    grey = 0, 0, 0, 6
    black = 0, 0, 0, 100
    school_profile_blue = 5, 1, 0, 0
    col_width = 160

# todo make col_width and col_height relational to gutter


    define_grid(:columns => 6, :rows => 9, :gutter => 20)
# grid.show_all
# start_new_page

# first column
#     grid([1, 0], [3, 5]).show
#     grid.show_all
    i = 0
    count = 1
    foo = 0

    schools_decorated_with_cache_results.each do |school|

# header
#
#       school_cache = school.school_cache

      if school.is_high_school
        fill_color blue_line
        text_box "GRADES 9-12",
                 :at => [250, 735],
                 :width => col_width,
                 :height => 20,
                 :size => 8
        # :style => :bold
        stroke do
          stroke_color blue_line
          horizontal_line 0, 535, :at => 725
        end
      elsif school.is_k8
        fill_color grey
        text_box "GRADES PK-8",
                 :at => [250, 735],
                 :width => col_width,
                 :height => 20,
                 :size => 8
        # :style => :bold
        stroke do
          stroke_color grey
          horizontal_line 0, 535, :at => 725
        end
      end

      grid([i, 0], [i+2, 5]).bounding_box do
        move_down 18
        # grid([0, 0], [2, 1]).show
        school_cache = school.school_cache
        grid([0, 0], [2, 1]).bounding_box do
          # stroke_color blue_line
          fill_color school_profile_blue
          fill_rounded_rectangle([0, cursor], col_width, 225, rect_edge_rounding)
          fill_color 100, 20, 20, 20
          move_down 5
          text_box school.name,
                   #
                   :at => [5, cursor],
                   :width => col_width,
                   :height => 40,
                   :size => 10,
                   :style => :bold

          move_down 40
          fill_color black
          text_box " #{school.process_level} | #{school.decorated_school_type} | #{school.district.name}",
                   :at => [5, cursor],
                   :width => col_width,
                   :height => 20,
                   :size => 6
#
          move_down 15

          bounding_box([1, cursor], :width => 0, :height => 0) do
            move_down 2
            if school_cache.overall_gs_rating == '1'
              image "app/assets/images/pyoc/overall_rating_1.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '2'
              image "app/assets/images/pyoc/overall_rating_2.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '3'
              image "app/assets/images/pyoc/overall_rating_3.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '4'
              image "app/assets/images/pyoc/overall_rating_4.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '5'
              image "app/assets/images/pyoc/overall_rating_5.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '6'
              image "app/assets/images/pyoc/overall_rating_6.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '7'
              image "app/assets/images/pyoc/overall_rating_7.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '8'
              image "app/assets/images/pyoc/overall_rating_8.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '9'
              image "app/assets/images/pyoc/overall_rating_9.png", :at => [15, cursor], :scale => 0.25
            elsif school_cache.overall_gs_rating == '10'
              image "app/assets/images/pyoc/overall_rating_10.png", :at => [15, cursor], :scale => 0.25
            else
              image "app/assets/images/pyoc/pre_k_pyoc.png", :at => [30, cursor], :scale => 0.25
            end

            move_down 25
            fill_color black
            text_box "Overall rating",
                     :at => [17, cursor],
                     :width => 25,
                     :height => 25,
                     :size => 6,
                     :style => :bold

          end

          data = [
              ['Test score rating', school_cache.test_scores_rating],
              ['Student growth rating', school_cache.student_growth_rating],
              ['College readiness', school_cache.college_readiness_rating],
          ]
          table(data, :column_widths => [80, 10],
                :position => 55,
                :cell_style => {size: 7, :height => 12, :padding => [0, 0, 1, 0], :text_color => black}) do
            cells.borders = []
            columns(1).font_style = :bold
          end

          move_down 10
          stroke do
            stroke_color grey
            horizontal_line 5, (col_width - 5), :at => cursor
          end

          move_down 5
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
                :cell_style => {size: 6, :padding => [0, 0, 0, 0], :text_color => black}) do
            cells.borders = []
            row(0).font_style = :bold
            row(0).size = 7
            row(0).padding = [0, 0, 5, 10]

          end

          bounding_box([1, 100], :width => 0, :height => 0) do
            move_down 10
            if i%2 == 0
              image "app/assets/images/pyoc/PYOC_Icons-03.png", :at => [5, cursor], :scale => 0.2
            else
              image "app/assets/images/pyoc/PYOC_Icons-04.png", :at => [5, cursor], :scale => 0.2
            end
          end
          move_down 5
          data =[[school.street],
                 ["#{school.city}, #{school.state} #{school.zipcode}"],
                 ["Phone: #{school.phone}"],
                 [' '],
                 ['School Hours:'],
                 [school_cache.start_time && school_cache.start_time ? "#{school_cache.start_time} - #{school_cache.end_time}" : 'n/a']
          ]

          # require 'pry'; binding.pry;

          table(data,
                :position => 60,
                :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => black}) do
            cells.borders = []
          end

          move_down 10
          fill_color 100, 20, 20, 20
          text_box "#{school_cache.best_known_for}",
                   :at => [5, cursor],
                   :width => 155,
                   :height => 30,
                   :size => 7,
                   :style => :italic

        end
        # # second column
        #     grid([1,2],[3,3]).show
        grid([0, 2], [2, 3]).bounding_box do
          fill_color black
          text_box "At a glance",
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 8,
                   :style => :bold

          move_down 10
          stroke do
            stroke_color blue_line
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5

          image_path_school_size= "app/assets/images/pyoc/school_size_pyoc.png"
          image_path_transportation= "app/assets/images/pyoc/transportation_pyoc.png"
          image_path_before_care= "app/assets/images/pyoc/before_care_pyoc.png"
          image_path_after_care= "app/assets/images/pyoc/after_care_pyoc.png"
          image_path_uniform= "app/assets/images/pyoc/uniform_pyoc.png"
          image_path_pre_k= "app/assets/images/pyoc/pre_k_pyoc.png"

          data = [[{:image => image_path_school_size, :scale => 0.25}, 'School size', school_cache.students_enrolled],
                  # data = [[{:image => image_path, :scale => 0.2}, 'School size', "123"],
                  [{:image => image_path_transportation, :scale => 0.25}, 'Transportation',
                   school_cache.transportation == "Yes" || school_cache.transportation == "No" ? school_cache.transportation : "n/a"],
                  [{:image => image_path_before_care, :scale => 0.25}, 'Before care',
                   school_cache.before_care == "Yes" || school_cache.before_care == "No" ? school_cache.before_care : "n/a"],
                  [{:image => image_path_after_care, :scale => 0.25}, 'After care',
                   school_cache.after_school == "Yes" || school_cache.after_school == "No" ? school_cache.after_school : "n/a"],
                  [{:image => image_path_uniform, :scale => 0.25}, 'Uniform/Dress code', school_cache.dress_code],
                  [{:image => image_path_pre_k, :scale => 0.25}, 'Pre K', school_cache.early_childhood_programs]
          ]

          table(data, :column_widths => [30, 100, 30],
                :row_colors => [white, grey],
                :cell_style => {size: 8, :padding => [2, 5, 2, 5]}) do
            cells.borders = []
            columns(2).font_style = :bold
            column(2).align = :right

            cells.style(:height => 13)
          end

          move_down 10

          fill_color grey
          fill_rounded_rectangle([0, cursor], col_width, 85, 5)

          move_down 5
          fill_color black


          text_box "Application",
                   :at => [5, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 8,
                   :style => :bold

          move_down 10
          stroke do
            stroke_color blue_line
            horizontal_line 5, col_width - 5, :at => cursor
          end

          move_down 5
          data = [
              ['Deadlines', school_cache.deadline],
              ['Tuition', school_cache.tuition],
              ['Financial aid', school_cache.aid],
              ['Voucher accepted', school_cache.voucher],
              ['Tax scholarship', school_cache.tax_scholarship],
          ]

          table(data, :column_widths => [110, 50],
                :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
            cells.borders = []
            columns(1).font_style = :bold
            column(1).align = :right
            cells.style(:height => 12)
          end
        end

#
# # third column
#       grid([0, 4], [2, 5]).show
        grid([0, 4], [2, 5]).bounding_box do
          fill_color black
          text_box "Diversity",
                   :at => [0, cursor],
                   :width => 75,
                   :height => 11,
                   :size => 8,
                   :style => :bold
          move_down 10
          stroke do
            stroke_color blue_line
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5

          ethnicity_data = school_cache.formatted_ethnicity_data.to_a
          ethnicity_data << ['Free and reduced lunch', school_cache.free_and_reduced_lunch != "?" ? school_cache.free_and_reduced_lunch : "n/a"]
          ethnicity_data.each_with_index do |i|
          end

          table(ethnicity_data, :column_widths => [130, 30],
                :row_colors => [white, grey],
                :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
            cells.borders = []
            columns(1).font_style = :bold
            column(1).align = :right
            cells.style(:height => 11)
          end

          move_down 10
          text_box 'Our grads go to?',
                   :at => [0, cursor],
                   :width => 75,
                   :height => 11,
                   :size => 8,
                   :style => :bold

          move_down 10
          data = [
              [school_cache.destination_school_1 ? school_cache.destination_school_1.truncate(47) : "n/a"],
              [school_cache.destination_school_2 ? school_cache.destination_school_2.truncate(47) : " "],
              [school_cache.destination_school_3 ? school_cache.destination_school_3.truncate(47) : " "]

          ]

          table(data, :column_widths => [col_width],
                :cell_style => {size: 7, :padding => [0, 0, 0, 0]}) do
            cells.borders = []
            cells.style(:height => 10)
          end

          move_down 5
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

          move_down 10
          text_box 'Programs',
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 8,
                   :style => :bold
          move_down 10
          stroke do
            stroke_color blue_line
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5

          image_path_world_languages = "app/assets/images/pyoc/world_languages.png"
          image_path_clubs = "app/assets/images/pyoc/clubs.png"
          image_path_sports = "app/assets/images/pyoc/sports.png"
          image_path_visual_arts = "app/assets/images/pyoc/visual_arts.png"
          no_program_data = "?"

          data = [[school_cache.world_languages != no_program_data ? {:image => image_path_world_languages, :scale => 0.3} : " ",
                   school_cache.clubs != no_program_data ? {:image => image_path_clubs, :scale => 0.3} : " ",
                   school_cache.sports != no_program_data ? {:image => image_path_sports, :scale => 0.3} : " ",
                   school_cache.arts_and_music != no_program_data ? {:image => image_path_visual_arts, :scale => 0.3} : " "]
          ]

          table(data, :column_widths => [20, 20, 20, 20],
                :cell_style => {:padding => [0, 0, 0, 0]}) do
            cells.borders = []
            cells.style(:height => 16)
          end
        end

        move_down 10
        if count % 3 != 0
          stroke do
            stroke_color grey
            horizontal_line 0, 535, :at => cursor
          end
        end

      end
      if count % 3 == 0

        start_new_page()
        i = 0
      else
        i += 3
      end

      image 'app/assets/images/pyoc/GS_logo-21.png', :at => [180, -10], :scale => 0.2
      draw_text page_number, :at => [270, -15], :size => 7
      text_box 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
               :at => [300, -10],
               :width => 200,
               :height => 10,
               :size => 7,
               :style => :italic

      count += 1
      foo += 1

    end
    puts "Time elapsed #{Time.now - beginning} seconds"
  end
end
