# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'nokogiri'
require 'fileutils'
require 'docx_mailmerge'
require 'nokogiri/diff'

SPEC_BASE_PATH = Pathname.new(File.expand_path(File.dirname(__FILE__)))
BASE_PATH = SPEC_BASE_PATH.join("sample_input")
class String
  def blank?
    self !~ /[^[:space:]]/
  end
end

RSpec::Matchers.define :be_same_xml_as do |expected|
  match do |actual|
    Nokogiri::XML(actual).diff(Nokogiri::XML expected).all? do |change, node|
      change.blank?
    end
  end
  diffable
end

def get_doc_text(docx_file_path)
  %x{#{GEM_ROOT}/docx2txt/docx2txt.pl < #{docx_file_path}}
end

def open_doc(doc_file_path)
  if RUBY_PLATFORM.include? "darwin"
    cmd = "open #{doc_file_path}"
    puts "\n************************************"
    puts "attempting to open created file in Word."
    puts "will run '#{cmd}'"
    puts "************************************"

    system cmd
  end
end

module DocxMailmerge
  module TestData
    BASE_PATH = SPEC_BASE_PATH.join("sample_input")
    DATA = {"First_Name" => "Anna", "Last_Name" => "Carey"}
    DOC_TYPES = %w{simple complex}
  end
end
