# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docx_mailmerge/version'

Gem::Specification.new do |spec|
  spec.name          = "docx_mailmerge"
  spec.version       = DocxMailmerge::VERSION
  spec.authors       = ["Anna Carey"]
  spec.email         = ["acarey@discoversdc.com"]
  spec.description   = %q{A ruby library to emulate the functionality of Microsoft Word's mail merge. }
  spec.summary       = %q{Given a Word .docx ducument with mailmerge fields and a hash of the data this gem will create a merged word document}
  spec.homepage      = "https://github.com/annaswims/docx_mailmerge"
  spec.license       = "MIT"
  spec.rdoc_options  = ["--charset=UTF-8"]
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("nokogiri")
  spec.add_dependency("zipruby")

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("simplecov")
  spec.add_development_dependency('nokogiri-diff')
  spec.add_development_dependency("rubocop")

end
