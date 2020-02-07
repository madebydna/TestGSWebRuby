class Grid

  attr_reader :result_array

  def initialize
    @result_array = Array.new(1000){Array.new(1000)}
  end

  def occupied?(point)
    !@result_array[point[0]][point[1]].nil?
  end

  def write_to_grid(point, char)
    @result_array[point[0]][point[1]] = char
  end

  def add_swath(h)
    h[:dimensions][0].to_i.times do |width|
      h[:dimensions][1].to_i.times do |height|
        point = [h[:point][0].to_i+width,h[:point][1].to_i+height]
        occupied?(point) ? write_to_grid(point, 'x') : write_to_grid(point, '.')
      end
    end
  end

  def count_overlap
    counter = 0
    @result_array.each do |arr|
      arr.each do |point_value|
        counter = counter+1  if point_value =='x'
      end
    end
    counter
  end

  def point_touched_multiple_times?(point)
    @result_array[point[0]][point[1]] == 'x'
  end

  def check_hash_for_overlap?(h)
    h[:dimensions][0].to_i.times do |width|
      h[:dimensions][1].to_i.times do |height|
        point = [h[:point][0].to_i+width,h[:point][1].to_i+height]
        return false if point_touched_multiple_times?(point)
      end
    end
    true
  end
end

if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]
puts "Going to open '#{filename}'"


def my_parse_arguments(line)
  hash = {}
  at_sign = line.index('@')
  semicolon = line.index(':')

  hash[:line_number] = line[1..(at_sign-1)]
  hash[:point] = line[(at_sign+1)..semicolon].split(',')
  hash[:dimensions] = line[(semicolon+1)..(line.length)].split('x')
  hash
end

grid = Grid.new

all_hashes = []
File.open(filename, "r") do |file_handle|
  file_handle.each_line do |line|
    h = my_parse_arguments line
    all_hashes << h
    grid.add_swath(h)
  end
end

puts grid.count_overlap

all_hashes.each do |h|
  puts h[:line_number]  if grid.check_hash_for_overlap?(h)
end



