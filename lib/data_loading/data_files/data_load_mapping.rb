class DataLoadMapping
  include ActiveModel::Validations

  attr_accessor :name,:source,:files

  validates :name, presence: true
  validates :source, presence: true
  validates :files, presence: true
  validate :files_to_be_array

  def files_to_be_array
    unless @files.kind_of?(Array)
      errors.add(:files, "Configuration for Files should be an array")
    end
  end

  def initialize(config)
    @config = config
    @name = config[:name]
    @source = config[:source]
    @files = [*config[:files]].each do |file_mapping|
      begin
        DataFileMapping.new(file_mapping)
      rescue => error
        log.error error
        next
      end
    end
  end

end
