module Jekyll
  # Sass plugin to convert .scss to .css
  #
  # Note: This is configured to use the new css like syntax available in sass.
  require 'sass'
  require 'bundler'
  class SassConverter < Converter
    safe true
    priority :low

     def matches(ext)
      ext =~ /scss/i
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      begin
        t = Time.now.strftime("%Y-%m-%d %H:%M:%S");
        puts "[#{t}] Performing Sass Conversion."
        engine = Sass::Engine.new(content, :syntax => :scss, :load_paths => ["./_includes/stylesheets/", "./assets/toolkit/stylesheets"], :line_numbers => true)
        engine.render
      rescue StandardError => e
        puts "[#{t}] !!! SASS Error - [Line #{e.sass_line}] -- #{e.to_s}"
      end
    end
  end
end
