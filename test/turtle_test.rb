# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'turtle'

class TurtleTest < Test::Unit::TestCase
   
  def test_simple
    t = Turtle.new
    filename = File.dirname(__FILE__) + '/simple.logo'
    t.read_lines(filename)
    t.show
    output_filename = File.dirname(__FILE__) + '/simple_turtle.txt'
    t.write_to_file(output_filename)
  end
  
  def test_complex
    t = Turtle.new
    filename = File.dirname(__FILE__) + '/complex.logo'
    t.read_lines(filename)
    t.show
    output_filename = File.dirname(__FILE__) + '/complex_turtle.txt'
    t.write_to_file(output_filename)
  end
end
