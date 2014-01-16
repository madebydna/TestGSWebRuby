#esp response keys and their pretty labels

value_file_name = File.join("#{Rails.root}/db/osp_value_label_map.txt")

[value_file_name].each do |file_name|
  if File.exist?(file_name)
    file = File.read(file_name)

    file.each_line do |line|
      fields = line.strip.split /\t/

      if fields.length < 3
        puts "(Warning) Too few field values for: #{line}. Excepted 3 fields, got #{fields.length}. Skipping row"
      else
        begin
          ResponseValue.create!(response_key: fields[0].strip, response_value: fields[1].strip, response_label: fields[2].strip)
        rescue
          puts "#{$!}  Could not insert new row for: \"#{line}\""
        end
      end
    end

  else
    puts "Could not find file: #{file_name}"
  end
end


