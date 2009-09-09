require 'pathname'
require 'tempfile'
require 'maruku'
require 'fileutils'

class Docapi
  
  FILES_TO_INCLUDE = {
    :javascripts => ["./javascripts/documentation/highlight.pack.js"],
    :stylesheets => ["./stylesheets/documentation/layout.css", "./stylesheets/documentation/syntax.css", "./stylesheets/documentation/highlighter/default.css"]
  }
  
  def initialize
    
  end
  
  def merge(input_path, output_path, options = {})
    input_dir = Pathname.new(input_path)
    raise ArgumentError, "Input directory does not exist" unless input_dir.directory?
    output_dir = Pathname.new(output_path || Pathname.getwd+"generated-doc")
    output_dir.mkpath
    output = File.open(output_dir+"index.html", "w+")
    output << header(:title => options[:title])
    convert_directory(input_dir, output)
    output << footer
    output.close
    # copy stylesheets and javascripts files
    FileUtils.cp_r(File.join(File.dirname(__FILE__), "..", "files", "."), output_dir)
  end
  
  def convert_directory(dir, output, level = 1)
    dir.entries.each do |entry|
      next if entry.to_s =~ /^\./
      path = dir+entry
      if path.directory?
        output << "<h#{level}>#{entry.to_s.gsub(/\d+-/, "").capitalize}</h#{level}>"
        convert_directory(path, output, level+1)
      else
        convert_file(path, output, level+1)
      end
    end
  end
  
  def convert_file(file, output, level = 1)
    case file.extname
    when ".md"
      output << Maruku.new( File.read(file) ).to_html
    when ".rb"
      blocks = []
      File.open(file, "r").each do |line|
        if line =~ /^=begin (.*)$/
          output << write_block(blocks.pop)
          blocks << {:content => "", :language => $1}
        elsif line =~ /^=end$/
          output << write_block(blocks.pop)
        else
          blocks << {:content => "", :language => "ruby"} if blocks.last.nil?
          blocks.last[:content] << line
        end
      end  
      output << write_block(blocks.pop)
    when ".html"
      output << File.read(file)
    end
  end
  
  def write_block(block)
    if block
      case block[:language]
      when "markdown", "text"
        Maruku.new( block[:content] ).to_html
      else
        '<pre><code class="'+block[:language]+'">'+block[:content]+'</code></pre>'
      end
    end
  end
  
  def generate(input_paths, output_path, options = {})
    require 'rdoc'
    require 'rdoc/rdoc'
    rdoc_options = %w{-f html --one-file --charset=UTF-8 -U}
    rdoc_options.concat input_paths
    output_dir = Pathname.new(output_path || Pathname.getwd+"documentation")
    raise ArgumentError, "Output directory '#{output_dir}' does not exist" unless output_dir.directory?
    rdoc_output = Tempfile.new("rdoc_output.html")
    old_stdout = $stdout
    begin
      # redirect stdout to the file
      $stdout = rdoc_output
      RDoc::RDoc.new.document(rdoc_options)
    ensure
      $stdout = old_stdout
    end
    rdoc_output.rewind
    documentation = rdoc_output.read
    rdoc_output.close
    date = documentation[/<tr><td>Modified:<\/td><td>(.*?)<\/td><\/tr>/, 1]
    methods = documentation.split("<h4>  method: ")
    methods.shift
    methods.map!{ |m| 
      ["<li>", m.gsub(/<blockquote><pre>.*/m, "").gsub(/<a name="(.+?)">(.*?)<br \/>\s*?<\/a>/m, "<div class=\"synopsis\"><a name=\"\\1\">\\2<a></div>").gsub(/<pre>(.*?)<\/pre>/m, "<pre><code>\\1</code></pre>"), "</li>"].join("")
    }.reverse!

    File.open(File.join(output_dir.realpath, "documentation.html"), "w+") do |f|
      f << '<ol class="methods">'
      methods.each{ |method| f << method }
      f << "</ol>"
    end
  end
  
  
  def header(options = {})
    output = []
    output << "<html><head><title>#{options[:title] || "Documentation"}</title>"
    FILES_TO_INCLUDE[:javascripts].each do |file|
      output << '<script type="text/javascript" src="'+file+'"></script>'
    end
    FILES_TO_INCLUDE[:stylesheets].each do |file|
      output << '<link media="screen" type="text/css" href="'+file+'" rel="stylesheet"/>'
    end
    output << '<script type="text/javascript">hljs.initHighlightingOnLoad();</script>'
    output << "</head><body>"
  end
  def footer
    output = []
    output << "</body></html>"
  end
  
end