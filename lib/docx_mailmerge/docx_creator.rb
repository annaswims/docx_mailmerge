module DocxMailmerge
  class DocxCreator
    attr_reader :template_path, :template_processor

    def initialize(template_path, data)
      @template_path = template_path
      @template_processor = DocxMerge.new(data)
    end

    def generate_docx_file(file_name = "output_#{Time.now.strftime("%Y-%m-%d_%H%M")}.docx")
      buffer = generate_docx_bytes
      File.open(file_name, 'wb') { |f| f.write(buffer) }
    end

    def generate_docx_bytes
      buffer = ''
      read_existing_template_docx do |template|
        create_new_zip_in_memory(buffer, template)
      end
      buffer
    end

    private

    def copy_or_template(entry_name, f)
      # Inside the word document archive is one file with contents of the actual document. Modify it.
      if entry_name == 'word/document.xml'
        template_processor.merge(f.read)
      else
        f.read
      end
    end

    def read_existing_template_docx
      ZipRuby::Archive.open(template_path) do |template|
        yield template
      end
    end

    def create_new_zip_in_memory(buffer, template)
      n_entries = template.num_files
      ZipRuby::Archive.open_buffer(buffer, ZipRuby::CREATE) do |archive|
        n_entries.times do |i|
          entry_name = template.get_name(i)
          template.fopen(entry_name) do |f|
            archive.add_buffer(entry_name, copy_or_template(entry_name, f))
          end
        end
      end
    end
  end
end
