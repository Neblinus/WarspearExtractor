# Warspear Online .pak contents extractor
require "fileutils"

# Assertions for greater safety
class AssertionError < RuntimeError
end

# Assert util method
def assert(condition, message)
  abort(message) unless condition
end

# Modesl the subfiles contained on the .pak file
class InPakDataFile
  def initialize(origin_file)
    assert(origin_file.is_a?(File), "Expected a file from which to extract the data")
    @start = origin_file.read(4).ord
    @size = origin_file.read(4).ord
    skip_irrelevant_bytes(5)
    @name = origin_file.read(55).gsub(/\x00.*/, '')
  end
  
  attr_reader :start, :size, :name
end

Object.private_constant :AssertionError, :InPakDataFile

module WarspearExtractor
  # Read-only for internal use
  @@source_file = ""
  
  def WarspearExtractor.source_file
    @@source_file
  end
  
  # Util for safe file operations
  def guard_wrapper(target_method, *arguments)
    assert(target_method.is_a?(Method), "Expected a method to be called with safe-guards")
    begin
      target_method.call(*arguments)
    rescue SystemCallError => exception
      STDERR.puts "Error on file operations: #{exception.message}"
    end
  end

  # Safely opens the file for reading
  def set_file_reading
    @@source_file = File.new(ARGV.fetch(0), "rb")
    unless is_valid_pak_file? then
      STDERR.puts "The file isn't a Warspear Online .pak file"
    end
  end
  
  # Ensures the file has a .pak header
  def is_valid_pak_file?
    @@source_file.read(4).eql?("MDPK")
  end
  
  # Advances the file cursor to skip unknown/irrelevant bytes
  def skip_irrelevant_bytes(bytes_count)
    assert(bytes_count.is_a?(Integer), "Expected an integer for the number of bytes to skip")
    @@source_file.seek(bytes_count, :CUR)
  end
  
  # Sets up the list of data files on the .pak file
  def get_pak_data_files
    skip_irrelevant_bytes(6)
    data_count = @@source_file.read(2).ord
    skip_irrelevant_bytes(16)
    files_list = []
    data_count.times do |index|
      files_list.append(InPakDataFile.new(@@source_file))
    end
    files_list
  end
  
  # Sets up a directory for extraction of the current file
  def set_data_extraction_dir(root_path, data_file)
    data_path = root_path + case File.dirname(data_file.name).eql?(".")
      when true then ""
      when false then File.dirname(data_file.name)
    end
    FileUtils.makedirs(data_path)
  end
  
  # Creates data files and write their content
  def write_extracted_data_file(source_path, target_file)
    file_instance = File.new(source_path + target_file.name, "wb")
    @@source_file.seek(target_file.start, :SET)
    file_instance.write(@@source_file.read(target_file.size))
    file_instance.close()
  end
  
  # Writes the data files from the .pak input
  def write_pak_data_files
    data_files_list = get_pak_data_files()
    base_path = ARGV.last.end_with?("/") ? ARGV.last : ARGV.last + "/"
    data_files_list.each do |file|
      set_data_extraction_dir(base_path, file)
      write_extracted_data_file(base_path, file)
    end
  end
  
  # Extracts the .pak contents to a directory
  def extract_pak_contents
    set_file_reading()
    write_pak_data_files()
    @@source_file.close()
  end
end

# TODO: use DI to make the module usable in-code
include WarspearExtractor
guard_wrapper(method(:extract_pak_contents))
