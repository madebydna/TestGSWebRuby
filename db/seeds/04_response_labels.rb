#esp response keys and their pretty labels

key_file_name = File.join("#{Rails.root}/db/osp_key_label_map.txt")
value_file_name = File.join("#{Rails.root}/db/osp_value_label_map.txt")

[key_file_name, value_file_name].each do |file_name|
  if File.exist?(file_name)
    file = File.read(file_name)

    file.each_line do |line|
      fields = line.strip.split /\t/

      if fields.length != 2
        puts "(Warning) Incorrect number of field values for: #{line}. Excepted 2 fields, got #{fields.length}. Skipping row"
      else
        begin
          ResponseValue.create!(response_value: fields[0].strip, response_label: fields[1].strip)
        rescue
          puts "#{$!}  Could not insert new row for: #{line}"
        end
      end
    end

  else
    puts "Could not find file: #{file_name}"
  end
end


