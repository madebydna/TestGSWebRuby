require_relative "../test_processor"

class SDTestProcessor20172018SBACSDSA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  source("combined.txt",[],col_sep: "\t") do |s|
    s.transform('Add test details', WithBlock) do |row|
      if row[:subject] == 'science'
        row[:notes] = 'DXT-3131: SD SDSA'
        row[:test_data_type] = 'SDSA'
        row[:test_data_type_id] = 364
      elsif row[:subject] == 'math' || row[:subject] == 'ela'
        row[:notes] = 'DXT-3131: SD SBAC'
        row[:test_data_type] = 'SBAC'
        row[:test_data_type_id] = 220      
      end
      row
    end 
    .transform('Add test description', WithBlock) do |row|
      if row[:year] == '2017'
        if row[:subject] == 'science'
          row[:description] = 'In 2016-17, students in South Dakota took the South Dakota Science Assessment (SDSA). The SDSA is administered to students in grades 5, 8, and 11.'
        elsif row[:subject] == 'math' || row[:subject] == 'ela'
          row[:description] = 'In 2016-17, students in South Dakota took the SBAC assessment in ELA and Math for grades 3-8 and 11.'
        end
      elsif row[:year] == '2018'
        if row[:subject] == 'science'
          row[:description] = 'In 2017-18 students in South Dakota took the South Dakota Science Assessment (SDSA). The SDSA is administered to students in grades 5, 8, and 11.'
        elsif row[:subject] == 'math' || row[:subject] == 'ela'
          row[:description] = 'In 2017-18, students in South Dakota took the SBAC assessment in ELA and Math for grades 3-8 and 11.'
        end
      end
      row
    end 
    .transform('Add test description', WithBlock) do |row|
      if row[:year] == '2017'
        if row[:subject] == 'science'
          row[:description] = 'In 2016-17, students in South Dakota took the South Dakota Science Assessment (SDSA). The SDSA is administered to students in grades 5, 8, and 11.'
        elsif row[:subject] == 'math' || row[:subject] == 'ela'
          row[:description] = 'In 2016-17, students in South Dakota took the SBAC assessment in ELA and Math for grades 3-8 and 11.'
        end
      elsif row[:year] == '2018'
        if row[:subject] == 'science'
          row[:description] = 'In 2017-18 students in South Dakota took the South Dakota Science Assessment (SDSA). The SDSA is administered to students in grades 5, 8, and 11.'
        elsif row[:subject] == 'math' || row[:subject] == 'ela'
          row[:description] = 'In 2017-18, students in South Dakota took the SBAC assessment in ELA and Math for grades 3-8 and 11.'
        end
      end
      row
    end 
    .transform('Fix prof bands', WithBlock) do |row|
      row[:proficiency_band_id] = row[:proficiency_band_id].to_f
      row
    end 

  end

  def config_hash
    {
      source_id: 46,
      state: 'sd'
    }
  end
end

SDTestProcessor20172018SBACSDSA.new(ARGV[0], max: nil).run