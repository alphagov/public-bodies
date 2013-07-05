require "./json_converter"
require "jekyll"

describe Jekyll::FrontEndGenerator do
  it 'returns a string when given a public body hash' do
    generator = Jekyll::FrontEndGenerator.new
    generator.generateBodyPage({}).should be_an_instance_of String
  end
end
