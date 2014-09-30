class PyocPdf < Prawn::Document
  def initialize(schools_decorated_with_cache_results)

    beginning = Time.now
    # super( :top_margin => 18,
    #        :bottom_margin => 18)
    super()

    rect_edge_rounding = 10
    blue_line_stroke = 70, 15, 0, 0
    white = 0, 0, 0, 0
    grey = 0, 0, 0, 6
    black = 0, 0, 0, 100
    school_profile_blue = 5, 1, 0, 0 #elementary
    middle_school_fill = 45, 0 ,10, 0
    high_school_fill = 10, 45, 0, 9
    prek_fill = 9, 5, 100, 5
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

    # while i and count <= 4 and foo <= 4
    schools_decorated_with_cache_results.each do |school|
      puts school

# header
      image 'app/assets/images/pyoc/PYOC_Icons-05.png', :at => [270,740], :scale => 0.2

      grid([i, 0], [i+2, 5]).bounding_box do
        move_down 18
        # grid([0, 0], [2, 1]).show
        grid([0, 0], [2, 1]).bounding_box do
          stroke_color blue_line_stroke
          # if fake_data[foo][:grade_level] == 'e'
            fill_color school_profile_blue
          # elsif fake_data[foo][:grade_level] == 'm'
          #   fill_color middle_school_fill
          # elsif fake_data[foo][:grade_level] == 'h'
          #   fill_color high_school_fill
          # else
          #   fill_color prek_fill
          # end
          fill_and_stroke_rounded_rectangle([0, cursor], col_width, 225, rect_edge_rounding)
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
          # stroke_color grey
          # stroke_rounded_rectangle([20, cursor], 130, 30, rect_edge_rounding)


          bounding_box([1, cursor], :width => 0, :height => 0) do
            move_down 2
            image "app/assets/images/pyoc/PYOC_Icons-06.png", :at => [30, cursor], :scale => 0.2
            move_down 15
            fill_color black
            text_box "Overall rating",
                     :at => [30, cursor],
                     :width => 25,
                     :height => 25,
                     :size => 5,
                     :style => :bold

          end

          data = [
              ['Test score rating', "#{school.school_cache.test_scores_rating}"],
              ['Student growth rating', "#{school.school_cache.student_growth_rating}"],
              ['College readiness', "#{school.school_cache.college_readiness_rating}"],
          ]
          table(data, :column_widths => [80, 10],
                :position => 55,
                :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => black}) do
            cells.borders = []
            columns(1).font_style = :bold
          end

          move_down 5
          stroke do
            stroke_color grey
            horizontal_line 1, (col_width - 1), :at => cursor
          end

          move_down 5
          data = [
              ['A', '3', 'C'],
              ['Other score', 'Other score', 'Other score'],
          ]
          table(data, :column_widths => [53,53,53],
                :position => 5,
                :cell_style => {size:7, :padding => [0,0 ,0,0],:text_color => black}) do
            cells.borders = []
            row(0).font_style = :bold
            row(0).size = 11
            row(0).padding = [0,0 ,5,10]

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
          data =[["#{school.street}"],
                 ["#{school.city}, #{school.state} #{school.zipcode}"],
                 ["Phone: #{school.phone}"],
                 [' '],
                 ['School Hours:'],
                 ["#{school.school_cache.start_time} - #{school.school_cache.end_time}"]
          ]

          table(data,
                :position => 60,
                :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => black}) do
            cells.borders = []
          end

          move_down 10
          fill_color 100, 20, 20, 20
          text_box "#{school.school_cache.best_known_for}",
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
            stroke_color blue_line_stroke
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5
          image_path = "app/assets/images/pyoc/PYOC_Icons-01.png"
          data = [[{:image => image_path, :scale => 0.3}, 'School size', "#{school.school_cache.students_enrolled}"],
          # data = [[{:image => image_path, :scale => 0.2}, 'School size', "123"],
                  [{:image => image_path, :scale => 0.3}, 'Transportation',
                   "#{school.school_cache.transportation}" == "Yes" || "#{school.school_cache.transportation}" == "No" ? "#{school.school_cache.transportation}" : "N/A"],
                  [{:image => image_path, :scale => 0.3}, 'Before care',
                   "#{school.school_cache.before_care}" == "Yes" || "#{school.school_cache.before_care}" == "No" ? "#{school.school_cache.before_care}" : "N/A"],
                  [{:image => image_path, :scale => 0.3}, 'After care', '000'],
                  [{:image => image_path, :scale => 0.3}, 'Uniform/Dress code', '000'],
                  [{:image => image_path, :scale => 0.3}, 'Pre K', '000']
          ]

          table(data, :column_widths => [30, 100, 30],
                :row_colors => [white, grey],
                :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
            cells.borders = []
            columns(2).font_style = :bold
            column(2).align = :right

            cells.style(:height => 13)
          end

          move_down 10

          # if i % 2 == 0
          fill_color grey
          fill_rounded_rectangle([0, cursor], col_width, 110, 5)

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
            stroke_color blue_line_stroke
            horizontal_line 5, col_width, :at => cursor
          end

          move_down 5
          data = [
              ['Deadlines', "#{school.school_cache.deadline}"],
              # ['Tuition',  "#{school_cache.tuition}"],
              ['Financial aid', 'rolling'],
              # ['Voucher accepted', " #{school.school_cache.voucher}"],
              ['Tax scholarship', 'rolling'],
          ]

          # require 'pry'; binding.pry;

          table(data, :column_widths => [110,50],
                :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
            cells.borders = []
            columns(1).font_style = :bold
            column(1).align = :right
            cells.style(:height => 12)
          end



          # else
          #   fill_color school_profile_blue
          #   fill_rounded_rectangle([0, cursor], col_width, 95, 5)
          #   fill_color black
          #   text_box "A whole other module",
          #            :at => [5, cursor],
          #            :width => 75,
          #            :height => 10,
          #            :size => 8,
          #            :style => :italic
          #
          #   move_down 10
          #   stroke do
          #     stroke_color blue_line_stroke
          #     horizontal_line 5, col_width, :at => cursor
          #   end

          # end

        end

#
# # third column
#       grid([0, 4], [2, 5]).show
        grid([0, 4], [2, 5]).bounding_box do
          fill_color black
          text_box "Diversity",
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 8,
                   :style => :bold
          move_down 10
          stroke do
            stroke_color blue_line_stroke
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5

          data = [
              ['more infomation', '3%']
          ]

          table(data * 8, :column_widths => [130,30],
                :row_colors => [white, grey],
                :cell_style => {size: 8, :padding => [0, 5, 0, 5]}) do
            cells.borders = []
            columns(1).font_style = :bold
            column(1).align = :right
            cells.style(:height => 12)
          end

          move_down 10
          text_box 'Our grads go to?',
                   :at => [0, cursor],
                   :width => 75,
                   :height => 12,
                   :size => 8,
                   :style => :bold
          # move_down 10
          # stroke do
          #   stroke_color blue_line_stroke
          #   horizontal_line 0, col_width, :at => cursor
          # end

          move_down 10
          data = [
              # ['really awesome schools'],[''],['really awesome schools']
              ['really awesome schools']
          ]

          table(data, :column_widths => [160],
                :cell_style => {size: 8, :padding => [0, 0, 0, 0]}) do
            cells.borders = []
            cells.style(:height => 11)
          end

          move_down 10
          data = [
              ['ELL offering:', 'SPED offering:'],
              ['Basic', 'Intensive']
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
            stroke_color blue_line_stroke
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5

          image_path_chess = "app/assets/images/pyoc/PYOC_Icons-02.png"
          image_path_score = "app/assets/images/pyoc/PYOC_Icons-06.png"

          data = [[]]

          sprite = 0
          while sprite < 4
            if sprite % 2 == 0
              data[0].push({:image => image_path_chess, :scale => 0.3})
            elsif sprite % 3 == 0
              data[0].push({:image => image_path_score, :scale => 0.2})
            else
              data[0].push('')
            end
            sprite += 1
          end
          #
          table(data, :column_widths => [40, 40, 40, 40],
                :cell_style => {:padding => [0, 0, 0, 0]}) do
            cells.borders = []
            cells.style(:height => 20)
          end
        end
      end

      if count % 3 == 0

        start_new_page()
        i = 0
      else
        i += 3
      end

      image 'app/assets/images/pyoc/PYOC_Icons-05.png', :at => [180,-10], :scale => 0.2
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
