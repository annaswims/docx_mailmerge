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
merge_data = {first_name: "Anita", last_name: "Borg"}
```
and then
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

You may also replace all missing values with XXXXXXXXXX by setting the second argument to "blank" or "nil" to DocxMailmerge::DocxCreator.new
```ruby
docx_template = DocxMailmerge::DocxCreator.new(template_docx_file_path, "blank")
```


## Contributing
To run the test you'll need docx2txt, a Perl library available at http://docx2txt.sourceforge.net/.  The test expects it at #{GEM_ROOT}/docx2txt/docx2txt.pl

If you'd automatically like to open the resulting word documents when you run rspec `WORD=true rspec`



