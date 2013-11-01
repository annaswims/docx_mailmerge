require 'spec_helper'
require 'docx_merge_spec'

describe "integration test", integration: true do

  let(:output_dir) { SPEC_BASE_PATH.join("sample_output") }
  DOCX_FILE_PATH = {
              complex: "#{BASE_PATH}/complex/unmerged/doc.docx",
              simple:  "#{BASE_PATH}/simple/unmerged/doc.docx"
    }
  before(:all) do
    FileUtils.rm_rf(output_dir) if File.exists?(output_dir)
    Dir.mkdir(output_dir)
  end

  DocxMailmerge::TestData::DOC_TYPES.each do |doc_type|
    unmerged_docx_file_path = "#{BASE_PATH}/#{doc_type}/unmerged/doc.docx"
    handmerged_docx_file_path = "#{BASE_PATH}/#{doc_type}/handmerged/doc.docx"

    context "should process in incoming docx" do
      it "generates a valid zip file (.docx)" do
        output_file_path = "#{output_dir}/IntegrationTest#{doc_type}.docx"
        DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).generate_docx_file(DocxMailmerge::TestData::DATA, output_file_path)

        archive = ZipRuby::Archive.open(output_file_path)
        archive.close
        open_doc(output_file_path)
        output_doc_text = get_doc_text(output_file_path)
        expected_doc_text = get_doc_text(handmerged_docx_file_path)
        pending
        puts "%%%#{output_doc_text}%%%"
        puts "$$$#{expected_doc_text}$$$"
        output_doc_text.should == expected_doc_text

      end

      it "returns an array of merge fields" do
        merge_fields = DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).merge_field_names
        merge_fields.should =~  %w{First_Name Last_Name}
      end

      it "generates a file with the same contents as the input docx" do
        input_entries = ZipRuby::Archive.open(unmerged_docx_file_path) { |z| z.map(&:name) }
        output_file_path = "#{output_dir}/consistency#{doc_type}.docx"
        DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).generate_docx_file(DocxMailmerge::TestData::DATA, output_file_path)
        output_entries = ZipRuby::Archive.open(output_file_path) { |z| z.map(&:name) }

        input_entries.should == output_entries
      end

    end

  end
end
