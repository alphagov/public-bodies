require "./_plugins/json_converter"
require "jekyll"
require "builder"

describe Jekyll::FrontEndGenerator do
  before do
    @generator = Jekyll::FrontEndGenerator.new
    @testdata = {"name" => "Animal Procedures Committee"}
  end

  describe 'createTable' do
    it 'creates an empty table from the empty list' do
      @generator.createTable([]).should == '<table></table>'
    end
    it 'creates a table from a list of lists of values' do
      @generator.createTable([["item1", "item2", "item3"]]).should == '<table><tr><td>item1</td><td>item2</td><td>item3</td></tr></table>'
    end
    it 'generates headers when given a header' do
      @generator.createTable([["item1", "item2", "item3"]], ['head1', 'head2', 'head3']).should == '<table><tr><th>head1</th><th>head2</th><th>head3</th></tr><tr><td>item1</td><td>item2</td><td>item3</td></tr></table>'
    end
  end
end
