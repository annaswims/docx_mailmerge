require 'spec_helper'
require 'sample_input/xml_snippets'

module DocxMailmerge
  module TestData
    DATA = {"First_Name" => "Anna", "Last_Name" => "Carey"}
  end
end



describe DocxMailmerge::DocxMerge do
  BASE_PATH = SPEC_BASE_PATH.join("sample_input") 
let(:data) { Marshal.load(Marshal.dump(DocxMailmerge::TestData::DATA)) } # deep copy

TEXT_FILE_PATH = {
                  complex:  File.read("#{BASE_PATH}/complex/unmerged/doc/word/document.xml"),
                  simple: File.read("#{BASE_PATH}/simple/unmerged/doc/word/document.xml")
}

  TEXT_FILE_PATH.each do |xml_type, file_path|

    context "#{xml_type} valid xml" do
       let(:parser) { DocxMailmerge::DocxMerge.new( file_path) }

      it "should return an array of fields" do
        out = parser.field_names
        out.should =~ %w{First_Name Last_Name}
      end

      it "should render and still be valid XML" do
        Nokogiri::XML.parse(file_path).should be_xml
        out = parser.merge(data)
        Nokogiri::XML.parse(out).should be_xml
      end

      it "should accept non-ascii characters" do
        data["First_Name"] = "老师"
        out = parser.merge(data)
        out.index("老师").should >= 0
        Nokogiri::XML.parse(out).should be_xml
      end

      it "should replace a simple merge field with data" do
        pending
        # parser = DocxMailmerge::DocxMerge.new(XmlSnippets.doc(XmlSnippets::SIMPLE_UNMERGED))
        # merged_xml = parser.merge(data)
        # expected_xml = Nokogiri::XML.parse(XmlSnippets.doc(XmlSnippets::SIMPLE_UNMERGED)).to_xml
        # merged_xml.should be_same_xml_as expected_xml
      end

      it "should enter Missing Value text for a blank value" do
        dataless_parser = DocxMailmerge::DocxMerge.new(file_path)
        out = dataless_parser.merge({})
        out.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should >= 0
      end
    end
  end



  context "No merge fields" do
    let(:nomerge_xml) { File.read("#{BASE_PATH}/KitchenSink/doc/word/document.xml") }
    let(:nomerge_parser) { DocxMailmerge::DocxMerge.new(nomerge_xml) }

    it "leave everything that is not a merge field the same" do
      input = Nokogiri::XML.parse(nomerge_xml).to_xml
      out = nomerge_parser.merge(data)
      input.should be_same_xml_as out
    end
  end
end