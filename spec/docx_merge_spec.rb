require 'spec_helper'

module DocxMailmerge
  module TestData
    DATA = {"First_Name" => "Anna", "Last_Name" => "Carey"}
  end
end

describe DocxMailmerge::DocxMerge do
  let(:data) { Marshal.load(Marshal.dump(DocxMailmerge::TestData::DATA)) } # deep copy
  let(:parser) { DocxMailmerge::DocxMerge.new(data) }
  let(:base_path) { SPEC_BASE_PATH.join("sample_input") }
  let(:simple_xml) { File.read("#{base_path}/simple/unmerged/doc/word/document.xml") }
  let(:complex_xml) { File.read("#{base_path}/complex/unmerged/doc/word/document.xml") }
  let(:nomerge_xml){ File.read("#{base_path}/complex/unmerged/doc/word/document.xml") }
  let(:merged_simple_xml) { File.read("#{base_path}/KitchenSink/doc/word/document.xml") }

  context "simple valid xml" do
    it "should render and still be valid XML" do
      Nokogiri::XML.parse(simple_xml).should be_xml
      out = parser.merge(simple_xml)
      Nokogiri::XML.parse(out).should be_xml
    end

    it "should accept non-ascii characters" do
      data["First_Name"] = "老师"
      out = parser.merge(simple_xml)
      out.index("老师").should >= 0
      Nokogiri::XML.parse(out).should be_xml
    end

    it "leave everything that is not a merge field the same" do
       input = Nokogiri::XML.parse(merged_simple_xml).to_xml
       out = parser.merge(merged_simple_xml)
       input.should be_same_xml_as out
    end

    it "should enter Missing Value text for a blank value" do
      dataless_parser = DocxMailmerge::DocxMerge.new({})
      out = dataless_parser.merge(simple_xml)
      out.index(DocxMailmerge::DocxMerge::MISSING_VALUE_TEXT).should >= 0
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
