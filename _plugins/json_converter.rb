require "json"
require "jekyll"
require "builder"
require "csv"
require "./_plugins/csvconverter.rb"

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

  class PublicBodyJSONPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = self.cleanName(json["name"]) + ".json"
      self.read_yaml(File.join(base, '_layouts'), 'json.json')
      self.process(@name)
      @content = JSON.dump(json)
    end
  end
  
  class PublicBodyCSVPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = self.cleanName(json["name"]) + ".csv"
      self.read_yaml(File.join(base, '_layouts'), 'json.json')
      self.process(@name)
      @content = CSV.generate do |csv|
        csv<<(json.keys)
        csv<<(json.map { |k,v| v })
      end
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
      self.data['data'] = json['bodies']
    end
  end

  class DepartmentJSONPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = "index.json"
      self.read_yaml(File.join(base, '_layouts'), 'json.json')
      self.process(@name)
      @content = JSON.dump(json)
    end
  end

  class DepartmentCSVPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = "index.csv"
      self.read_yaml(File.join(base, '_layouts'), 'json.json')
      self.process(@name)
      @content = CSV.generate do |csv|
        csv<<(json['bodies'][0].keys)
        json['bodies'].each do |body|
          csv<<(body.map { |key, value| value })
        end
      end
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
      self.data['departments'] = json.map { |department| {"name" => department["name"], "cleanname" => cleanName(department["name"])}}
      self.data['data'] = json
    end
  end

  class HomeJSONPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = "index.json"
      self.read_yaml(File.join(base, '_layouts'), 'json.json')
      self.process(@name)
      @content = JSON.dump(json).to_s
    end
  end

  class HomeCSVPage < Page
    def cleanName(name)
      return name.downcase.gsub(/ /, '-').gsub(/[^A-Za-z0-9-]/, '')
    end
    def initialize(site, base, dir, json)
      @site = site
      @base = base
      @dir = dir
      @name = "index.csv"
      self.read_yaml(File.join(base, '_layouts'), 'json.json')
      self.process(@name)
      @content = CSV.generate do |csv|
        csv<<(json[0]['bodies'][0].keys)
        json.each do |department|
          department['bodies'].each do |body|
            csv<<(body.map { |key, value| value })
          end
        end
      end
    end
  end
  
  def csvToHash
    csv = CSV.read('public-bodies.csv')
    csv = csv.group_by { |dept| dept[:name] }
    csv.each do |k,v|
      h[k] = v.map do |b|
        return Hash(b)
      end
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
        if File.fnmatch('*/public-bodies/public-bodies.csv', in_path)
          generatePage(file.path, site)
        end
      end
    end

    def generatePage(staticfilepath, site)
      csv = CSV.read(staticfilepath, {
                       :headers => :first_row
                     })
      bodies = csv.map { |body| PublicBody.new(body) }.group_by { |body| body.department }.map{ |name, bodies| {'name' => name, 'bodies' => bodies.map{|body| body.to_hash } } }

      site.pages << self.generateHomePage(bodies, site)
      site.pages << self.generateHomeJSONPage(bodies, site)
      site.pages << self.generateHomeCSVPage(bodies, site)
      bodies.each do |department|
        site.pages << self.generateDeptPage(department, site)
        site.pages << self.generateDepartmentJSONPage(department, site)
        site.pages << self.generateDepartmentCSVPage(department, site)
        department['bodies'].each do |body|
          site.pages << self.generatePublicBodyPage(body, site)
          site.pages << self.generatePublicBodyJSONPage(body, site)
        end
      end
    end

    def generateDepartmentJSONPage(json, site)
      return DepartmentJSONPage.new(site, site.source, cleanName(json["name"]), json)
    end
    def generateDepartmentCSVPage(json, site)
      return DepartmentCSVPage.new(site, site.source, cleanName(json["name"]), json)
    end
    def generateDeptPage(json, site)
      return DepartmentPage.new(site, site.source, cleanName(json["name"]) , json)
    end
    def generateHomePage(json, site)
      return HomePage.new(site, site.source, '.', json)
    end
    def generateHomeJSONPage(json, site)
      return HomeJSONPage.new(site, site.source, '.', json)
    end
    def generateHomeCSVPage(json, site)
      return HomeCSVPage.new(site, site.source, '.', json)
    end
    def generatePublicBodyPage(json, site)
      return PublicBodyPage.new(site, site.source, json["clean-department"], json)
    end
    def generatePublicBodyJSONPage(json, site)
      return PublicBodyJSONPage.new(site, site.source, json["clean-department"], json)
    end
    def generatePublicBodyJSONPage(json, site)
      return PublicBodyCSVPage.new(site, site.source, json["clean-department"], json)
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
