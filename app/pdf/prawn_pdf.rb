class PrawnPdf < Prawn::Document
  def initialize(canonical_url)
    super()

    rect_edge_rounding = 10
    blue_line_stroke = 60, 100, 0, 0
    grey = 3, 3, 3, 3
    white_fill = 0, 0, 0, 0
    black_fill = 100, 100, 100, 100
    light_blue_fill = 15, 0, 0, 0
    col_width = 160

# todo make col_width and col_height relational to gutter
    define_grid(:columns => 6, :rows => 11, :gutter => 20)
# start_new_page
# grid.show_all


# first column
#     grid([1, 0], [3, 5]).show
    grid([1, 0], [3, 5]).bounding_box do
      # grid([0, 0], [2, 1]).show
      grid([0, 0], [2, 1]).bounding_box do
        stroke_color blue_line_stroke
        fill_color light_blue_fill
        fill_and_stroke_rounded_rectangle([0, cursor], col_width, 175, rect_edge_rounding)
#     # # school name
#       move_down 5
        fill_color 100, 20, 20, 20
        text_box "Name of a really really really no joke really long school 00000000000 000000000000 000000000000 00000000000000 000000000",
                 #
                 :at => [5, cursor],
                 :width => col_width,
                 :height => 40,
                 :size => 10,
                 :style => :bold
#
        move_down 40
        fill_color black_fill
        text_box "1-6 | Private | Some District",
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
            # [{:image => image_path, :scale => 0.15, :rowspan => 2}, 'Test score rating', '3'],
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
          image "app/assets/images/pyoc/PYOC_Icons-03.png", :at => [5, cursor], :scale => 0.2
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

      end

#
# # third column
#       grid([0, 4], [2, 5]).show
      grid([0, 4], [2, 5]).bounding_box do
        fill_color black_fill
        text_box "Other text",
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
      end

      move_down 5
      stroke_color blue_line_stroke
      stroke_horizontal_rule
      # 0, 1000, :at => cursor
    end
  end
end
