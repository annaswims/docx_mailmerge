# DocxMailmerge

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'docx_mailmerge'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docx_mailmerge

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

  # dmfc = DocxMerge.new("/Users/annacarey/code/nextgear/legalgen/doc/complex/unmerged/doc/word/document.xml", {"First_Name"=>"Anna", "Last_Name" => "Carey"})


# zipruby specifically because:
  #  - rubyzip does not support in-memory zip file modification (in you process sensitive info
  #  that can't hit the filesystem).
  #  - people report errors opening in word docx files when altered with rubyzip (search stackoverflow)

  # zipruby-compat, which is my fork of zipruby that changes the module Zip::* to ZipRuby::*,
  #  so it does not collide with rubyzip in same project.
  #  - see https://github.com/jawspeak/zipruby-compatibility-with-rubyzip-fork
  # THIS gem is not installed to rubyforge. Thus, you MUST on your own, in your Gemspec, add a dependency
  # to zipruby-compat. Example:
  #   gem "zipruby-compat", :git => "git@github.com:jawspeak/zipruby-compatibility-with-rubyzip-fork.git", :tag => "v0.3.7"