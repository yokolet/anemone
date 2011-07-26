# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'turtle'

class TurtleTest < Test::Unit::TestCase
  def setup
     @filename = File.dirname(__FILE__) + '/simple.logo'
  end
   
  def test_read_lines
    t = Turtle.new
    t.read_lines(@filename)
    t.show
  end
  
  def test_dispatch
    args = ["61"]
    t = Turtle.new
    t.dispatch(args)
    assert_equal(61, t.board_size)
    
    args = ["RT", "135"]
    assert_equal("RT 135", t.dispatch(args))
    args = ["REPEAT", "2", "[", "RT", "90", "FD", "15", "]"]
    assert_equal("REPEAT #{%w(2 [ RT 90 FD 15 ])}", t.dispatch(args))
    
    args = []
    assert_nil(t.dispatch(args))
  end
  
  

  def test_foo
    #TODO: Write test
    flunk "TODO: Write test"
    # assert_equal("foo", bar)
  end
end
