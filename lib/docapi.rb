require 'pathname'
require 'tempfile'
require 'maruku'
require 'fileutils'

class Docapi
  
  FILES_TO_INCLUDE = {
    :javascripts => ["./javascripts/documentation/highlight.pack.js", "./javascripts/documentation/jquery-1.3.2.min.js", "./javascripts/documentation/jquery.tableofcontents.min.js", "./javascripts/documentation/documentation.js"],
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
    output << convert_directory(input_dir)
    output << footer
    output.close
    # copy stylesheets and javascripts files
    FileUtils.cp_r(File.join(File.dirname(__FILE__), "..", "files", "."), output_dir)
  end
  
  def convert_directory(dir, level = 1)
    output = []
    dir.entries.each do |entry|
      next if entry.to_s =~ /^\./
      path = dir+entry
      title = File.basename(entry).gsub(/\d+-/, "").gsub(/\..+?$/, "")
      output << "<div class='docapi-section #{title.downcase}'>"
      if path.directory?
        output << "<h#{level}>#{title.capitalize}</h#{level}>"
        output << convert_directory(path, level+1)
      else
        output << convert_file(path)
      end  
      output << '</div>'
    end
    output.flatten
  end
  
  def convert_file(file)
    case file.extname
    when ".md"
      Maruku.new( File.read(file) ).to_html
    when ".rb"
      process_file_sections(file, 'ruby', [/^=begin (.*)$/, /^=end$/])
    when ".py"
      process_file_sections(file, 'python', [/^''' (.*)$/, /^'''$/])
    when ".sh"
      process_file_sections(file, 'bash', [/^<<ENDCOMMENT >\/dev\/null$/, /^ENDCOMMENT$/])
    when ".html"
      File.read(file)
    end
  end
  
  
  def process_file_sections(file, language, regexps)
    blocks = []
    output = ["<div class='docapi-subsection'><div class='docapi-title'>#{File.basename(file).gsub(/^\d+-/, "")}</div>"]
    File.open(file, "r").each do |line|
      if line =~ regexps.first
        output << write_block(blocks.pop)
        blocks << {:content => "", :language => ($1 || "markdown")}
      elsif line =~ regexps.last
        output << write_block(blocks.pop)
      else
        blocks << {:content => "", :language => language} if blocks.last.nil?
        blocks.last[:content] << line
      end
    end  
    output << write_block(blocks.pop)
    output << '</div>'
  end
  
  def write_block(block)
    if block
      case block[:language]
      when "markdown", "text"
        Maruku.new( block[:content] ).to_html.gsub(/<pre class='(.+?)'><code>(.*?)<\/code><\/pre>/m, '<pre><code class="\1">\2</code></pre>')
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
      ["<div class='docapi-subsection'>", m.gsub(/<blockquote><pre>.*/m, "").gsub(/<a name="(.+?)">(.*?)<br \/>\s*?<\/a>/m, "<div class='docapi-title'><a name=\"\\1\">\\2<a></div>").gsub(/<h2>(.*?)<\/h2>/m, "<div class='docapi-subtitle'>\\1</div>").gsub(/<pre>(.*?)<\/pre>/m, "<pre><code>\\1</code></pre>"), "</div>"].join("")
    }

    File.open(File.join(output_dir.realpath, "documentation.html"), "w+") do |f|
      # sort methods by :call-seq: length ASC. A bit dirty but...
      methods.sort_by{|m| method = m[/<div class='docapi-title'><a name=".*?">(.+?)<a><\/div>/, 1].length}.each{ |method| f << method }
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
    output << %Q{
  	<!--[if IE]>
  	<style type="text/css" media="screen">
  		body {padding-right: 320px}
  	</style>
  	<![endif]-->}
    output << "</head><body>"
  end
  def footer
    output = []
    output << "<div id='generation-date'>Generated at: <span class='date'>#{Time.now.to_s}</span></div>"
    output << "</body></html>"
  end
  
end