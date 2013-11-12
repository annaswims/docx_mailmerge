module DocxMailmerge
  class DocxCreator
    attr_reader :template_path, :template_processor

    def initialize(template_path)
      @template_path = template_path
    end

    def generate_docx_file(data, file_name = "output_#{Time.now.strftime("%Y-%m-%d_%H%M")}.docx")
      buffer = generate_docx_bytes(data)
      File.open(file_name, 'wb') { |f| f.write(buffer) }
    end

    def generate_docx_bytes(data)
      buffer = ''
      read_existing_template_docx do |template|
        create_new_zip_in_memory(buffer, template, data)
      end
      buffer
    end

    def merge_field_names
      read_existing_template_docx do |template|
        file = template.fopen("word/document.xml")
        template_processor =  DocxMerge.new(file.read)
        template_processor.field_names
      end
    end

    private

    def copy_or_template(entry_name, f, data)
      # Inside the word document archive is one file with contents of the actual document. Modify it.
      if entry_name == 'word/document.xml'
        template_processor =  DocxMerge.new(f.read)
        template_processor.merge(data)
      elsif entry_name == "word/settings.xml"
        remove_mailmerge_node(f.read)
      else
        f.read
      end
    end

    def remove_mailmerge_node(settings_xml)
      doc = Nokogiri::XML(settings_xml) { |config| config.strict.noblanks }
      doc.xpath("//w:mailMerge").remove
      doc.to_xml
    end

    def read_existing_template_docx
      Zip::Archive.open(template_path) do |template|
        yield template
      end
    end

    def create_new_zip_in_memory(buffer, template, data)
      n_entries = template.num_files
      Zip::Archive.open_buffer(buffer, Zip::CREATE) do |archive|
        n_entries.times do |i|
          entry_name = template.get_name(i)
          template.fopen(entry_name) do |f|
            archive.add_buffer(entry_name, copy_or_template(entry_name, f, data)) unless  entry_name == "word/_rels/settings.xml.rels"
          end
        end
      end
    end
  end
end
