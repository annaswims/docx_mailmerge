require 'rubygems'
require 'nokogiri'
require 'zipruby'
require "docx_mailmerge/version"

module DocxMailmerge
end

require 'docx_mailmerge/docx_merge'
require 'docx_mailmerge/docx_creator'

GEM_ROOT = File.expand_path '../..', __FILE__
