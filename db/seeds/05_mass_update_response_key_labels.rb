#esp response keys and their pretty labels

key_file_name = File.join("#{Rails.root}/db/osp_key_label_map.txt")

[key_file_name].each do |file_name|
  if File.exist?(file_name)
    file = File.read(file_name)

    file.each_line do |line|
      fields = line.strip.split /\t/

      if fields.length < 2
        puts "(Warning) Too few field values for: #{line}. Excepted 2 fields, got #{fields.length}. Skipping row"
      else
        begin
          CategoryData.where(response_key: fields[0]).update_all(label: fields[1])
        rescue
          puts "#{$!}  Could not insert new row for: \"#{line}\""
        end
      end
    end

  else
    puts "Could not find file: #{file_name}"
  end
end