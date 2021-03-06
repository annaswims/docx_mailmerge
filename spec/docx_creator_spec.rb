require 'spec_helper'
require 'docx_merge_spec'

describe "integration test", integration: true do

  OUTPUT_DIR = SPEC_BASE_PATH.join("sample_output")

  before(:all) do
    FileUtils.rm_rf(OUTPUT_DIR) if File.exists?(OUTPUT_DIR)
    Dir.mkdir(OUTPUT_DIR)
  end

  doc_type = DocxMailmerge::TestData::DOC_TYPE
  unmerged_docx_file_path = "#{BASE_PATH}/#{doc_type}/unmerged/doc.docx"
  handmerged_docx_file_path = "#{BASE_PATH}/#{doc_type}/handmerged/doc.docx"

  context "should process a #{doc_type} incoming docx" do
    it "generates a valid document (.docx)- file" do
      output_file_path = "#{OUTPUT_DIR}/IntegrationTest#{doc_type}.docx"
      DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).generate_docx_file(DocxMailmerge::TestData::DATA, output_file_path)

      open_doc(output_file_path)

      output_doc_text = get_doc_text(output_file_path)
      expected_doc_text = get_doc_text(handmerged_docx_file_path)
      output_doc_text.gsub(/\s/, '').should == expected_doc_text.gsub(/\s/, '')

    end

    it "generates a valid document (.docx) - bytes " do
      output_file_path = "#{OUTPUT_DIR}/IntegrationTest#{doc_type}.docx"
      docx_bytes = DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).generate_docx_bytes(DocxMailmerge::TestData::DATA)

      File.open(output_file_path, 'wb') { |f| f.write(docx_bytes) }
      open_doc(output_file_path)  if ENV["WORD"]

      output_doc_text = get_doc_text(output_file_path)
      expected_doc_text = get_doc_text(handmerged_docx_file_path)
      output_doc_text.gsub(/\s/, '').should == expected_doc_text.gsub(/\s/, '')

    end

    it "returns an array of merge fields" do
      merge_fields = DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).merge_field_names
      merge_fields.should =~  %w{first_name last_name}
    end

    it "generates a file with the same contents as the input docx" do
      input_entries = Zip::Archive.open(unmerged_docx_file_path) { |z| z.map(&:name) }
      output_file_path = "#{OUTPUT_DIR}/consistency#{doc_type}.docx"
      DocxMailmerge::DocxCreator.new(unmerged_docx_file_path).generate_docx_file(DocxMailmerge::TestData::DATA, output_file_path)
      output_entries = Zip::Archive.open(output_file_path) { |z| z.map(&:name) }
      input_entries.delete("word/_rels/settings.xml.rels")
      input_entries.should =~ output_entries
    end

    it "should convert case appropriately" do
      output_file_path = "#{OUTPUT_DIR}/IntegrationTestCase.docx"
      test_data = {"entity_legal_name" => 'thIs is a test'}
      case_docx_file_path = "#{BASE_PATH}/cases/unmerged/doc.docx"
      DocxMailmerge::DocxCreator.new(case_docx_file_path).generate_docx_file(test_data, output_file_path)
      case_docx_file_path_expected = "#{BASE_PATH}/cases/handmerged/doc.docx"
      output_doc_text = get_doc_text output_file_path
      expected_doc_text = get_doc_text  case_docx_file_path_expected
      output_doc_text.gsub(/\s/, '').should == expected_doc_text.gsub(/\s/, '')
    end


    it "should replace nil data with a string" do
      output_file_path = "#{OUTPUT_DIR}/IntegrationTestNil.docx"
      DocxMailmerge::DocxCreator.new(unmerged_docx_file_path, "nil").generate_docx_file({}, output_file_path)
      open_doc(output_file_path)
      output_doc_text = get_doc_text(output_file_path)
      output_doc_text.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should be >= 0
    end

  end

end
