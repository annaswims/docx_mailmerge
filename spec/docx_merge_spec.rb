require 'spec_helper'
require 'sample_input/xml_snippets'

module DocxMailmerge
  module TestData
    DATA = {"First_Name" => "Anna", "Last_Name" => "Carey"}
  end
end

describe DocxMailmerge::DocxMerge do
  let(:base_path) { SPEC_BASE_PATH.join("sample_input") }
  let(:simple_xml) { File.read("#{base_path}/simple/unmerged/doc/word/document.xml") }
  let(:complex_xml) { File.read("#{base_path}/complex/unmerged/doc/word/document.xml") }
  let(:nomerge_xml) { File.read("#{base_path}/KitchenSink/doc/word/document.xml") }

  let(:data) { Marshal.load(Marshal.dump(DocxMailmerge::TestData::DATA)) } # deep copy

  let(:simple_parser) { DocxMailmerge::DocxMerge.new(simple_xml) }
  let(:complex_parser) { DocxMailmerge::DocxMerge.new(complex_xml) }
  let(:nomerge_parser) { DocxMailmerge::DocxMerge.new(nomerge_xml) }

  context "simple valid xml" do
    it "should return an array of fields" do
      out = simple_parser.field_names
      out.should =~ %w{First_Name Last_Name}
    end

    it "should render and still be valid XML" do
      Nokogiri::XML.parse(simple_xml).should be_xml
      out = simple_parser.merge(data)
      Nokogiri::XML.parse(out).should be_xml
    end

    it "should accept non-ascii characters" do
      data["First_Name"] = "老师"
      out = simple_parser.merge(data)
      out.index("老师").should >= 0
      Nokogiri::XML.parse(out).should be_xml
    end

    it "leave everything that is not a merge field the same" do
      input = Nokogiri::XML.parse(nomerge_xml).to_xml
      out = nomerge_parser.merge(data)
      input.should be_same_xml_as out
    end

    it "should enter Missing Value text for a blank value" do
      dataless_parser = DocxMailmerge::DocxMerge.new(simple_xml)
      out = dataless_parser.merge({})
      out.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should >= 0
    end

    it "should replace a simple merge field with data" do
      pending
      parser = DocxMailmerge::DocxMerge.new(XmlSnippets.doc(XmlSnippets::SIMPLE_UNMERGED))
      merged_xml = parser.merge(data)
      expected_xml = Nokogiri::XML.parse(XmlSnippets.doc(XmlSnippets::SIMPLE_UNMERGED)).to_xml
      merged_xml.should be_same_xml_as expected_xml
    end

  end

  context "simple valid xml" do

    it "should replace a complex merge field with data" do
      pending
      merged_xml = parser.merge(XmlSnippets::COMPLEX_UNMERGED, data)
      merged_xml.should be_same_xml_as XmlSnippets::COMPLEX_MERGED
    end

    it "should return an array of fields" do
      out = complex_parser.field_names
      out.should =~ %w{First_Name Last_Name}
    end

  end
end
  # it "should replace all simple keys with values" do
  #   non_array_keys = data.reject { |k, v| v.class == Array }
  #   non_array_keys.keys.each do |key|
  #     xml.index("$#{key.to_s.upcase}$").should >= 0
  #     xml.index(data[key].to_s).should be_nil
  #   end
  #   out = parser.merge(simple_xml)

  #   non_array_keys.each do |key|
  #     out.index("$#{key}$").should be_nil
  #     out.index(data[key].to_s).should >= 0
  #   end
  # end

  # it "should replace all array keys with values" do
  #   xml.index("#BEGIN_ROW:").should >= 0
  #   xml.index("#END_ROW:").should >= 0
  #   xml.index("$EACH:").should >= 0

  #   out = parser.merge(simple_xml)

  #   out.index("#BEGIN_ROW:").should be_nil
  #   out.index("#END_ROW:").should be_nil
  #   out.index("$EACH:").should be_nil

  #   [:roster, :event_reports].each do |key|
  #     data[key].each do |row|
  #       row.values.map(&:to_s).each do |row_value|
  #         out.index(row_value).should >= 0
  #       end
  #     end
  #   end
