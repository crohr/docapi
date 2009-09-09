# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{docapi}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cyril Rohr"]
  s.date = %q{2009-09-09}
  s.default_executable = %q{docapi}
  s.description = %q{RDoc template for generating API documentation.}
  s.email = %q{cyril.rohr@gmail.com}
  s.executables = ["docapi"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/docapi",
     "docapi.gemspec",
     "files/javascripts/documentation/highlight.pack.js",
     "files/stylesheets/documentation/highlighter/ascetic.css",
     "files/stylesheets/documentation/highlighter/brown_paper.css",
     "files/stylesheets/documentation/highlighter/brown_papersq.png",
     "files/stylesheets/documentation/highlighter/dark.css",
     "files/stylesheets/documentation/highlighter/default.css",
     "files/stylesheets/documentation/highlighter/far.css",
     "files/stylesheets/documentation/highlighter/github.css",
     "files/stylesheets/documentation/highlighter/idea.css",
     "files/stylesheets/documentation/highlighter/ir_black.css",
     "files/stylesheets/documentation/highlighter/magula.css",
     "files/stylesheets/documentation/highlighter/school_book.css",
     "files/stylesheets/documentation/highlighter/school_book.png",
     "files/stylesheets/documentation/highlighter/sunburst.css",
     "files/stylesheets/documentation/highlighter/vs.css",
     "files/stylesheets/documentation/highlighter/zenburn.css",
     "files/stylesheets/documentation/layout.css",
     "lib/docapi.rb",
     "test/code/reference_api.rb",
     "test/doc/1-README.md",
     "test/doc/2-documentation/documentation.html",
     "test/doc/3-tutorials/2-ruby/example-1.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/crohr/docapi}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{RDoc template for generating API documentation.}
  s.test_files = [
    "test/code/reference_api.rb",
     "test/doc/3-tutorials/2-ruby/example-1.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
