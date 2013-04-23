require 'yaml'
require 'haml'
require 'maruku'

module Docapi
  class CLI

    TEMPLATE = <<TEMPLATE
- methods.each do |method|
  .docapi-subsection
    .docapi-title
      %a{:name => method["name"].gsub(/\W/,' ').squeeze(' ').gsub(/\s/,'-')}= method["name"]
    .docapi-content
      = method["html_comment"].gsub(/<h2>(.*?)<\\/h2>/m, '<div class="docapi-subtitle">\\1</div>')
TEMPLATE

    FILES_TO_INCLUDE = {
      :javascripts => ["./javascripts/documentation/highlight.pack.js", "./javascripts/documentation/jquery-1.3.2.min.js", "./javascripts/documentation/jquery.tableofcontents.min.js", "./javascripts/documentation/documentation.js"],
      :stylesheets => ["./stylesheets/documentation/layout.css", "./stylesheets/documentation/syntax.css", "./stylesheets/documentation/highlighter/default.css"]
    }
    
    def merge(input_path, output_path, options = {})
      input_dir = Pathname.new(input_path)
      raise ArgumentError, "Input directory does not exist" unless input_dir.directory?
      output_dir = Pathname.new(output_path || Pathname.getwd+"generated-doc")
      output_dir.mkpath
      output = File.open(output_dir+"index.html", "w+")
      output << header(:title => options[:title]).join("")
      output << convert_directory(input_dir).join("")
      output << footer.join("")
      output.close
      # copy stylesheets and javascripts files
      FileUtils.cp_r(File.join(File.dirname(__FILE__), "..", "files", "."), output_dir)
    end
    
    def convert_directory(dir, level = 1)
      output = []
      dir.entries.each do |entry|
        next if entry.to_s =~ /^\./ || entry.to_s == "created.rid"
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
      require 'rdoc/generator/docapi'
      require 'tmpdir'
      temporary_output_path = File.join(Dir.tmpdir, "docapi")
      rdoc_options = %w{-f docapi --charset=UTF-8 -U --quiet -o}
      rdoc_options << temporary_output_path
      rdoc_options.concat input_paths
      output_dir = Pathname.new(output_path || Pathname.getwd+"documentation")
      raise ArgumentError, "Output directory '#{output_dir}' does not exist" unless output_dir.directory?
      RDoc::RDoc.new.document(rdoc_options)
      documentation = YAML.load_file(File.join(temporary_output_path, "index.yaml"))
      html = Haml::Engine.new(TEMPLATE, :ugly => true).render(Object.new, :methods => documentation["methods"], :options => options)  
      File.open(File.join(output_dir.realpath, "documentation.html"), "w+") do |f|
        f << html.gsub(/<pre>(.*?)<\/pre>/im, '<pre><code>\1</code></pre>')
      end
    end
    
    
    def header(options = {})
      output = []
      output << "<html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"><title>#{options[:title] || "Documentation"}</title>"
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
end
