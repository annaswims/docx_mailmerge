module DocxMailmerge
  class DocxMerge

    attr_reader :doc, :data

    def initialize(data)
      @data = data
    end

    def field_names
      (simple_field_names+complex_field_names).uniq
    end

    def merge(file)
      @doc = Nokogiri::XML(file)
      simple_merge
      complex_merge
      @doc.to_s
    end

    private

    def simple_merge_nodes
      @doc.xpath("//w:fldSimple[contains(@w:instr,'MERGEFIELD')]")
    end

    def complex_merge_nodes
      @doc.xpath("//w:instrText[contains(text(),'MERGEFIELD')]")
    end

    def simple_field_names
      simple_merge_nodes.collect do |simple_node|
        simple_node["w:instr"].match(/ MERGEFIELD \"(.*)\"/)[1]
      end
    end

    def complex_field_names
      complex_merge_nodes do |complex_node|
        complex_node.content.match(/ MERGEFIELD \"(.*)\"/)[1]
      end
    end

    def simple_merge
      simple_merge_nodes.each do |simple_node|
        field_name = simple_node["w:instr"].match(/ MERGEFIELD \"(.*)\"/)[1]
        simple_node.search(".//w:t").first.content = @data[field_name]
        simple_node.replace(simple_node.children)
      end
    end

    def complex_merge
      complex_merge_nodes.each do |complex_node|
        field_name = complex_node.content.match(/ MERGEFIELD \"(.*)\"/)[1]
        complex_node.parent.previous_element.remove
        complex_node.parent.next_element.remove
        text_node = complex_node.parent.next_element
        text_node.search(".//w:t").first.content = @data[field_name]
        search_result = ""
        while text_node.next_element && search_result.blank?
          n = text_node.next_element
          search_result = n.search('.//w:fldChar[@w:fldCharType="end"]')
          n.remove
        end
        complex_node.parent.remove
      end
    end

  end
end
