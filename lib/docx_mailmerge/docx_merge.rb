module DocxMailmerge
  class DocxMerge
    MISSING_VALUE_TEXT = "XXXXXXXXXX"
    WORD_CASES = {upper: 'Upper', caps: 'Caps', first_caps: 'FirstCap', lower: 'Lower' }

    attr_reader :doc, :data

    def initialize(file)
      @original_doc = Nokogiri::XML(file) { |config| config.strict.noblanks }
      @doc = @original_doc.clone
    end

    def field_names
      (simple_field_names + complex_field_names).uniq
    end

    def merge(data)
      @doc = @original_doc.clone
      simple_merge(data)
      complex_merge(data)
      @doc.to_xml
    end

    private

    def simple_merge_nodes
      @doc.xpath("//w:fldSimple[contains(@w:instr,'MERGEFIELD')]")
    end

    def complex_merge_nodes
      @doc.xpath("//w:instrText[contains(text(),'MERGEFIELD')]")
    end

    def simple_field_names
      simple_merge_nodes.map do |simple_node|
        mergefield_name simple_node["w:instr"]
      end
    end

    def complex_field_names
      complex_merge_nodes.map do |complex_node|
        mergefield_name complex_node.content
      end
    end

    def simple_merge(data)
      simple_merge_nodes.each do |simple_node|
        ft = field_text(data, simple_node["w:instr"])
        simple_node.search(".//w:t").first.content = ft
        simple_node.replace(simple_node.children)
      end
    end

    def complex_merge(data)
      complex_merge_nodes.each do |complex_node|
        # begin tag
        complex_node.parent.previous_element.remove

        # separator tag
        complex_node.parent.next_element.remove

        text_node = complex_node.parent.next_element
        text_node.search(".//w:t").first.content = field_text(data, complex_node.content)

        # end tag and potientally more extra junk
        search_result = ""
        while text_node.next_element && (search_result.nil?  || search_result.empty?)
          search_result = text_node.next_element.search('.//w:fldChar[@w:fldCharType="end"]')
          text_node.next_element.remove
        end

        # mergfield tag
        complex_node.parent.remove
      end
    end

    def field_text(data, node)
      field_name = mergefield_name(node)
      merge_text = to_template_case(mergefield_format_name(node), data[field_name])
      merge_text || "#{MISSING_VALUE_TEXT}#{field_name}"
    end

    def mergefield_info(node)
      node.match(/MERGEFIELD\s*\"?(\w*)\"?\W*(\w*)/)
    end

    def mergefield_format_name(node)
      mergefield_info(node)[2]
    end

    def mergefield_name(node)
      mergefield_info(node)[1].downcase
    end

    #http://office.microsoft.com/en-us/word-help/format-merged-data-HP005187180.aspx
    def to_template_case(format_name, merge_text)
      case format_name
      when WORD_CASES[:upper] then
        merge_text.upcase
      when  WORD_CASES[:first_caps], WORD_CASES[:caps] then
        merge_text.gsub(/\b('?[a-z])/) {  Regexp.last_match[1].capitalize }
      when WORD_CASES[:lower] then
        merge_text.downcase
      else
        merge_text
      end
    end

  end
end
