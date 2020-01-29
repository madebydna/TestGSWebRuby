# frozen_string_literal: true

require 'zip'

module Exacttarget
  module Helpers
    class Zip
      def zip(local_path)
        file = File.new("#{local_path}.zip", "w")
        Zip::File.open(file.path, Zip::File::CREATE) do |zipfile|
          zipfile.add(File.basename(local_path), local_path)
        end
      end
    end
  end
end

