require 'spec_helper'

describe DocxMailmerge::DocxMerge do
  let(:data) { Marshal.load(Marshal.dump(DocxMailmerge::TestData::DATA)) } # deep copy

  doc_type = DocxMailmerge::TestData::DOC_TYPE
  xml_file = File.read("#{BASE_PATH}/#{doc_type}/unmerged/doc/word/document.xml")

  let(:parser) { DocxMailmerge::DocxMerge.new(xml_file) }

  it "should return an array of fields" do
    out = parser.field_names
    out.should =~ %w{first_name last_name}
  end

  it "should render and still be valid XML" do
    Nokogiri::XML.parse(xml_file).should be_xml
    out = parser.merge(data)
    Nokogiri::XML.parse(out).should be_xml
  end

  it "should accept non-ascii characters" do
    data["first_name"] = "老师"
    out = parser.merge(data)
    out.index("老师").should be >= 0
    Nokogiri::XML.parse(out).should be_xml
  end

  it "should replace a #{doc_type} merge field with data" do
    expected_file = File.read("#{BASE_PATH}/#{doc_type}/handmerged/doc/word/document.xml")

    parser = DocxMailmerge::DocxMerge.new(xml_file)
    merged_xml = parser.merge(data)
    expected_xml = (Nokogiri::XML(expected_file) { |config| config.strict.noblanks }).to_xml
    merged_xml.should be_same_xml_as expected_xml
  end

  it "should enter Missing Value text for a blank value" do
    dataless_parser = DocxMailmerge::DocxMerge.new(xml_file)
    out = dataless_parser.merge({"first_name" => " ", "last_name" => " "},"blank")
    out.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should >= 0
  end

   it "should enter Missing Value text for a nil value" do
    dataless_parser = DocxMailmerge::DocxMerge.new(xml_file)
    out = dataless_parser.merge({},"nil")
    out.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should >= 0
  end

  it "should not add missing value text if mark_missing_values is nil" do
    dataless_parser = DocxMailmerge::DocxMerge.new(xml_file)
    out = dataless_parser.merge({"first_name" => " "})
    out.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should eq nil
  end

  context "No merge fields" do
    let(:nomerge_xml) { File.read("#{BASE_PATH}/KitchenSink/doc/word/document.xml") }
    let(:nomerge_parser) { DocxMailmerge::DocxMerge.new(nomerge_xml) }

    it "leave everything that is not a merge field the same" do
      input = (Nokogiri::XML(nomerge_xml) { |config| config.strict.noblanks }).to_xml
      out = nomerge_parser.merge(data)
      input.should be_same_xml_as out
    end
  end
end
