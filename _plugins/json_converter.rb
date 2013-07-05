require "json"
require "jekyll"

module Jekyll
  class FrontEndGenerator < Generator
    safe true

    def generate(site)
      dir = "frontend"
      site.static_files.each do |file|
        in_path = file.path
        if(File.extname(in_path).downcase == ".json")
          out_path = dir + "/" + File.dirname(in_path) + "/" + File.basename(in_path, ".rb") + ".md"
          self.json_to_md(file.path)
        end
      end
    end
    
    def json_to_md(staticfilepath)
      file = File.open(staticfilepath)
      jsonstring = file.read
      file.close
      json = JSON.parse jsonstring
      if json.is_a? Array
        return self.generateDeptPage json
      elsif json.is_a? Hash
        if json.has_key? 'all_bodies'
          return self.generateHomePage json
        else
          return self.generateBodyPage json
        end
      end
      
    end

    def generateDeptPage json
    end
    def generateHomePage json
    end
    def generateBodyPage json
      return ""
    end
  end
end
