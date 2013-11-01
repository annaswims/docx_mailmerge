source 'https://rubygems.org'

# Specify your gem's dependencies in docx_mailmerge.gemspec
gemspec

# Forked to make zipruby play nicely with rubyzip if your project already uses it.
gem "zipruby-compat", :require => 'zipruby', :git => "git@github.com:jawspeak/zipruby-compatibility-with-rubyzip-fork.git", :tag => "v0.3.7"


group :development do
  gem 'debugger'
  gem 'thin'
  gem 'annotate'
  gem 'hirb'
  gem 'guard-rubocop'
  gem 'guard-rspec'
  gem 'rubocop'
  gem 'growl'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov'
end