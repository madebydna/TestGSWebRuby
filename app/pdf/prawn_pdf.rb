class PrawnPdf < Prawn::Document
  def initialize(canonical_url)

    beginning = Time.now
    super()

    rect_edge_rounding = 10
    blue_line_stroke = 60, 100, 0, 0
    grey = 3, 3, 3, 3
    white_fill = 0, 0, 0, 0
    black_fill = 100, 100, 100, 100
    light_blue_fill = 15, 0, 0, 0 #elementary
    middle_school_fill = 45, 0 ,10, 0
    high_school_fill = 10, 45, 0, 9
    prek_fill = 9, 5, 100, 5
    col_width = 160

    fake_data = Hash.new
    fake_data = [{:school_name => 'Short school name', :grade => '1-5', :grade_level => 'e', :type => 'Private', :district_name=> 'Perry Township'},
      {:school_name => 'Medium school name 000000 0000 00000 000000', :grade => '6-8', :grade_level => 'm', :type => 'Public', :district_name => 'dflkjsldk jisudfsidflskdjf'},
     {:school_name => 'Name of a really really really no joke really long school 00000000000 000000000000 000000000000 00000000000000 000000000', :grade => '9-12', :grade_level => 'h', :type => 'Charter', :district_name=> 'Blah Perry Township'},
     {:school_name => 'A Great School', :grade => 'PK', :grade_level => 'p', :type => 'Private', :district_name=> 'Perry Township'}
                ]

# todo make col_width and col_height relational to gutter
    define_grid(:columns => 6, :rows => 11, :gutter => 20)
# grid.show_all
# start_new_page



# first column
#     grid([1, 0], [3, 5]).show
#     grid.show_all
    i = 1
    count = 1
    foo = 0

    while i and count <= 4 and foo <= 4



      grid([i, 0], [i+2, 5]).bounding_box do
        # grid([0, 0], [2, 1]).show
        grid([0, 0], [2, 1]).bounding_box do
          stroke_color blue_line_stroke
          if fake_data[foo][:grade_level] == 'e'
            fill_color light_blue_fill
          elsif fake_data[foo][:grade_level] == 'm'
            fill_color middle_school_fill
          elsif fake_data[foo][:grade_level] == 'h'
            fill_color high_school_fill
          else
            fill_color prek_fill
          end
          fill_and_stroke_rounded_rectangle([0, cursor], col_width, 175, rect_edge_rounding)
          fill_color 100, 20, 20, 20
          text_box fake_data[foo][:school_name],
                   #
                   :at => [5, cursor],
                   :width => col_width,
                   :height => 40,
                   :size => 10,
                   :style => :bold

          move_down 40
          fill_color black_fill
          text_box "#{fake_data[foo][:grade]} | #{fake_data[foo][:type]} | #{fake_data[foo][:district_name]}",
                   :at => [5, cursor],
                   :width => col_width,
                   :height => 20,
                   :size => 7
#
          move_down 10
          stroke_color grey
          stroke_rounded_rectangle([20, cursor], 130, 30, rect_edge_rounding)

          bounding_box([1, 130], :width => 0, :height => 0) do
            move_down 2
            image "app/assets/images/pyoc/PYOC_Icons-06.png", :at => [30, cursor], :scale => 0.15
            move_down 15
            fill_color black_fill
            text_box "Overall rating",
                     :at => [30, cursor],
                     :width => 25,
                     :height => 25,
                     :size => 5,
                     :style => :bold

          end
#     #

# image_path = "app/assets/images/pyoc/PYOC_Icons-06.png"
          data = [
              ['Test score rating', '3'],
              ['Student growth rating', '2'],
              ['College readiness', '1'],
          ]
          table(data, :column_widths => [80, 10],
                :position => 55,
                :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => "000000"}) do
            cells.borders = []
            # row(0..1).columns(0..1).borders = [:bottom]
            columns(1).font_style = :bold
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
          data =[['123 address st'],
                 ['some state, CA 12345'],
                 ['Phone: 111-111-111'],
                 [''],
                 ['School Hours:'],
                 ['0;00-0:00']]

          table(data,
                :position => 60,
                :cell_style => {size: 7, :padding => [0, 0, 1, 0], :text_color => "000000"}) do
            cells.borders = []
          end

          move_down 10
          fill_color 100, 20, 20, 20
          text_box '"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed quis sollicitudin nisl, in tincidunt felis. Phasellus mauris odio, mattis et."',
                   :at => [5, cursor],
                   :width => 155,
                   :height => 30,
                   :size => 7,
                   :style => :italic

        end
# # second column
#     grid([1,2],[3,3]).show
        grid([0, 2], [2, 3]).bounding_box do
          fill_color black_fill
          text_box "At a glance",
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 7.5,
                   :style => :bold

          move_down 10
          stroke do
            stroke_color blue_line_stroke
            horizontal_line 0, col_width, :at => cursor
          end

          move_down 5
          image_path = "app/assets/images/pyoc/PYOC_Icons-01.png"
          data = [[{:image => image_path, :scale => 0.2}, 'School size', '852']] * 6

          table(data, :column_widths => [30, 100, 30],
                :row_colors => ['ffffff', 'eeeeee'],
                :cell_style => {size: 7, :padding => [0, 0, 0, 5]}) do
            cells.borders = []
            columns(2).font_style = :bold

            cells.style(:height => 10)
          end

          move_down 5

          if i % 2 == 0
          fill_color grey
          fill_rounded_rectangle([0, cursor], col_width, 95, 5)

          move_down 5
          fill_color black_fill


            text_box "Application",
                   :at => [5, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 7.5,
                   :style => :bold

          move_down 10
          stroke do
            stroke_color blue_line_stroke
            horizontal_line 5, col_width, :at => cursor
          end

          move_down 5
          data = [
              ['Deadlines', 'rolling']
          ]

          table(data * 7, :column_widths => [130,30],
                :cell_style => {size: 7, :padding => [0, 0, 0, 5]}) do
            cells.borders = []
            columns(1).font_style = :bold
            cells.style(:height => 10)
          end



          else
            fill_color light_blue_fill
            fill_rounded_rectangle([0, cursor], col_width, 95, 5)
            fill_color black_fill
            text_box "A whole other module",
                     :at => [5, cursor],
                     :width => 75,
                     :height => 10,
                     :size => 7.5,
                     :style => :italic

            move_down 10
            stroke do
              stroke_color blue_line_stroke
              horizontal_line 5, col_width, :at => cursor
            end

          end

        end

#
# # third column
#       grid([0, 4], [2, 5]).show
        grid([0, 4], [2, 5]).bounding_box do
          fill_color black_fill
          text_box "Diversity",
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 7,
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
                :row_colors => ['ffffff', 'eeeeee'],
                :cell_style => {size: 7, :padding => [0, 0, 0, 5]}) do
            cells.borders = []
            columns(1).font_style = :bold
            cells.style(:height => 10)
          end

          move_down 10
          text_box 'Our grads go to?',
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 7,
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

          table(data * 3, :column_widths => [160],
                # :row_colors => ['ffffff', 'eeeeee'],
                :cell_style => {size: 7, :padding => [0, 0, 0, 0]}) do
            cells.borders = []
            # columns(1).font_style = :bold
            cells.style(:height => 10)
          end

          move_down 5
          text_box 'Programs',
                   :at => [0, cursor],
                   :width => 75,
                   :height => 10,
                   :size => 7,
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
          # data = [[{:image => image_path_chess, :scale => 0.2}, {:image => image_path_chess, :scale => 0.2}, {:image => image_path_score, :scale => 0.1} ]]

          sprite = 0
          while sprite < 4
            if sprite % 2 == 0
              data[0].push({:image => image_path_chess, :scale => 0.2})
            elsif sprite % 3 == 0
              data[0].push({:image => image_path_score, :scale => 0.1})
            else
              data[0].push('')
            end
            sprite += 1
          end
          #
          table(data, :column_widths => [20, 20, 20, 20, 20, 20, 20, 20],
                :cell_style => {size: 7, :padding => [0, 0, 0, 5]}) do
            cells.borders = []
            cells.style(:height => 10)
          end



        end

        move_down 5
        stroke_color blue_line_stroke
        stroke_horizontal_rule
      end

      if count % 3 == 0
        start_new_page
        i = 1
      else
        i += 3

      end


      image 'app/assets/images/pyoc/PYOC_Icons-05.png', :at => [130,15], :scale => 0.3
      draw_text page_number, :at => [250, 0], :size => 7
      text_box 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
               :at => [300, 5],
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
