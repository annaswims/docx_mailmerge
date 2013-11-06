# DocxMailmerge

Docx MailMerge takes a Word document (.docx) with mail merge fields and replaces the mail merge fields with data.

## Installation

Add this line to your application's Gemfile:

    gem 'docx_mailmerge'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docx_mailmerge

## Usage
```ruby
docx_template = DocxMailmerge::DocxCreator.new(template_docx_file_path)
merge_data = {first_name: "Anita",last_name: "Borg"}
```
```ruby
  docx_template.generate_docx_file(merge_data, output_file_path)
```
or

```ruby
  docx_bytes = docx_template.generate_docx_bytes(merge_data)
```

You can also get an array of merge fields in a document
```ruby
  docx_template.merge_field_names
```



