require 'spec_helper'
require 'docx_merge_spec'

describe "integration test", integration: true do
  let(:data) { DocxMailmerge::TestData::DATA }
  let(:base_path) { SPEC_BASE_PATH.join("sample_input") }
  let(:simple_input_file) { "#{base_path}/simple/unmerged/doc.docx" }
  let(:complex_input_file) { "#{base_path}/compled/unmerged/doc.docx" }
  let(:output_dir) { "#{base_path}/sample_output" }
  let(:output_file) { "#{output_dir}/IntegrationTestOutput.docx" }

  before do
    FileUtils.rm_rf(output_dir) if File.exists?(output_dir)
    Dir.mkdir(output_dir)
  end

  context "should process in incoming docx" do
    it "generates a valid zip file (.docx)" do
      DocxMailmerge::DocxCreator.new(simple_input_file).generate_docx_file(data, output_file)

      archive = ZipRuby::Archive.open(output_file)
      archive.close

      puts "\n************************************"
      puts "   >>> Only will work on mac <<<"
      puts "NOW attempting to open created file in Word."
      cmd = "open #{output_file}"
      puts "  will run '#{cmd}'"
      puts "************************************"

      system cmd
    end
    
    it "returns an array of merge fields" do
      merge_fields = DocxMailmerge::DocxCreator.new(simple_input_file).merge_field_names
      merge_fields.should =~  %w{First_Name Last_Name}

    end
    it "generates a file with the same contents as the input docx" do
      input_entries = ZipRuby::Archive.open(simple_input_file) { |z| z.map(&:name) }
      DocxMailmerge::DocxCreator.new(simple_input_file).generate_docx_file(data, output_file)
      output_entries = ZipRuby::Archive.open(output_file) { |z| z.map(&:name) }

      input_entries.should == output_entries
    end
  end
end
