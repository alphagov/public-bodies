require "json"
require "jekyll"
require "builder"

module Jekyll
  class PublicBodyPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = self.cleanName(json["name"]) + ".html"
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'public_body.html')
      self.data['title'] = json["name"]
      self.data['data'] = json
    end
  end
  class DepartmentPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'department.html')
      self.data['title'] = json["name"]
      self.data['bodies'] = json['bodies']
    end
  end
  class HomePage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'department-list.html')
      self.data['title'] = "Non Departmental Public Bodies"
      self.data['departments'] = json['all_bodies'].keys.map { |departmentName| {"name" => departmentName, "cleanname" => cleanName(departmentName)}}
      self.data['data'] = json['all_bodies'].keys.each_with_object({}) { |departmentName, hsh|
        hsh[departmentName] = json['all_bodies'][departmentName].sort { |body1, body2|
          body1['government_funding'] <=> body2['government_funding']}}
    end
  end

  class FrontEndGenerator < Generator
    safe true
    def cleanName(name)
        return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    
    def generate(site)
      site.static_files.each do |file|
        in_path = file.path
        if File.extname(in_path).downcase == ".json"
          page = generatePage(file.path, site)
          if page != nil
            site.pages << page
          end
        end
      end
    end

    def generatePage(staticfilepath, site)
      file = File.open(staticfilepath)
      jsonstring = file.read
      file.close
      json = JSON.parse jsonstring
      if json.has_key? 'all_bodies'
        return self.generateHomePage json, site
      elsif json.has_key? 'bodies'
        return self.generateDeptPage json, site
      else
        return self.generateBodyPage json, site
      end
    end

    def generateDeptPage(json, site)
      
      return DepartmentPage.new(site, site.source, cleanName(json["name"]) , json)
    end
    def generateHomePage(json, site)
      return HomePage.new(site, site.source, '.', json)
    end
    def generateBodyPage(json, site)
      return PublicBodyPage.new(site, site.source, cleanName(json["department"]), json)
    end
    def createTable dataRows, headers=[]
      builder = Builder::XmlMarkup.new()
      xml = builder.table do |table|
        if not headers.empty?
          table.tr() do |tr|
            headers.each { |header| tr.th(header) }
          end
        end
        if not dataRows.empty?
          dataRows.each do |row|
            table.tr do |tr|
              row.each { |cell| tr.td(cell) }
            end
          end
        end
      end
      return xml
    end
  end
end
