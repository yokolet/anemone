# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'wired'

class WiredTest < Test::Unit::TestCase
  def test_find_index_of_operations
    w = Wired.new
    line = "0-------------|"
    o, p = [], []
    w.find_index_of_operations(line.split(""), o, p)
    assert_equal([0], o)
    assert_equal([14], p)
    line = "1-------------|                                 O--------------------|"
    o, p = [], []
    w.find_index_of_operations(line.split(""), o, p)
    assert_equal([0, 48], o)
    assert_equal([14, 69], p)
    line = "              O------------|                                         A------------@"
    o, p = [], []
    w.find_index_of_operations(line.split(""), o, p)
    assert_equal([14, 69], o)
    assert_equal([27], p)
    line = "                                                |                    |"
    o, p = [], []
    w.find_index_of_operations(line.split(""), o, p)
    assert_equal([], o)
    assert_equal([], p)
    
    line = "1--------------|                 |                N---------------------------------|                    |"
    o, p = [], []
    w.find_index_of_operations(line.split(""), o, p)
    assert_equal([0, 50], o)
    assert_equal([15, 84], p)
  end
  
  def test_insert
    w = Wired.new
    inputs = [
      "0-------------|".split(""),
      "              O------------|".split(""),
      "1-------------|            |".split(""),
      "                           X--------------------|".split(""),
      "1-------------|            |                    |".split(""),
      "              A------------|                    |".split(""),
      "1-------------|                                 O--------------------|".split(""),
      "                                                |                    |".split(""),
      "0-------------|                                 |                    |".split(""),
      "              N---------------------------------|                    |".split(""),
      "                                                                     |".split(""),
      "0-------------|                                                      |".split(""),
      "              O------------|                                         A------------@".split(""),
    
      "1-------------|            |                                         |".split(""),
      "                           X--------------------|                    |".split(""),
      "1-------------|            |                    |                    |".split(""),
      "              A------------|                    |                    |".split(""),
      "1-------------|                                 O--------------------|".split(""),
      "                                                |".split(""),
      "0-------------|                                 |".split(""),
      "              N---------------------------------|".split("")
    ]
    queue = []
    op_index = [0]
    parent_index = [14]
    w.insert(inputs[0], op_index, parent_index, 0, queue)
    assert_equal("0", queue[0].to_s)
    assert_equal(14, queue[0].parent_value)

    op_index = [14]
    parent_index = [27]
    w.insert(inputs[1], op_index, parent_index, 1, queue)
    assert_equal("O", queue[0].to_s)  # queue[0] should be "O," a top of a sub-tree
    assert_equal(27, queue[0].parent_value)

    op_index = [0]
    parent_index = [14, 27]
    w.insert(inputs[2], op_index, parent_index, 2, queue)
    assert_equal("1", queue[2].to_s)
    assert_equal(14, queue[2].parent_value)
    
    queue = []
    op_indexes = [[0], [14], [0], [27], [0], [14], [0, 48], [], [0], [14],
                  [], [0], [14, 69], [0], [27], [0], [14], [0, 48], [], [0], [14]]
    parent_indexes = [[14], [27], [14, 27], [48], [14, 27, 48], [27, 48], [14, 69], [48, 69], [14], [48, 69],
                      [69], [14, 69], [27, nil], [14, 27, 69], [48, 69], [14, 27, 48, 69], [27, 48, 69], [14, 69], [48], [14, 48], [48]]
    # sub-tree of "O" at root
    (0..9).each do |i|
      w.insert(inputs[i], op_indexes[i], parent_indexes[i], i, queue)
    end
    results = ["O", "X", "O", "A", "N", "0", "1", "1", "1", "0"]
    queue.each_with_index do |item, index|
      assert_equal(results[index], item.to_s)
    end
    results = [69, 48, 27, 27, 48, 14, 14, 14, 14, 14]
    queue.each_with_index do |item, index|
      assert_equal(results[index], item.parent_value)
    end
    
    queue = []
    # whole tree
    (0...inputs.length).each do |i|
      w.insert(inputs[i], op_indexes[i], parent_indexes[i], i, queue)
    end
    results = ["A", "O", "O", "X", "X", "O", "A", "N", "O", "A", "N", "0", "1", "1", "1", "0", "0", "1", "1", "1", "0"]
    queue.each_with_index do |item, index|
      assert_equal(results[index], item.to_s)
    end
    results = [nil, 69, 69, 48, 48, 27, 27, 48, 27, 27, 48, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14]
    queue.each_with_index do |item, index|
      assert_equal(results[index], item.parent_value)
    end
  end
  
  def test_process
    queue = []
    queue << OrNode.new(14, 27, 1)
    queue << ZeroNode.new(0, 14, 0)
    queue << OneNode.new(0, 14,2)
    result = queue[0].process(queue)
    assert_true(result)
    
    queue = []
    queue << XorNode.new(27, nil, 3)
    queue << AndNode.new(14, 27, 1)
    queue << NotNode.new(14, 27, 5)
    queue << ZeroNode.new(0, 14, 0)
    queue << OneNode.new(0, 14, 2)
    queue << OneNode.new(0, 14, 4)
    result = queue[0].process(queue)
    assert_false(result)
    
    queue = []
    queue << XorNode.new(27, nil, 3)
    queue << OrNode.new(14, 27, 1)
    queue << XorNode.new(14, 27, 5)
    queue << ZeroNode.new(0, 14, 0)
    queue << OneNode.new(0, 14, 2)
    queue << OneNode.new(0, 14, 4)
    queue << OneNode.new(0, 14, 6)
    result = queue[0].process(queue)
    assert_true(result)
    
    queue = []
    queue << XorNode.new(27, 48, 3)
    queue << OrNode.new(14, 27, 1)
    queue << AndNode.new(14, 27, 5)
    queue << ZeroNode.new(0, 14, 0)
    queue << OneNode.new(0, 14, 2)
    queue << OneNode.new(0, 14, 4)
    queue << OneNode.new(0, 14, 6)
    result = queue[0].process(queue)
    assert_false(result)
    
    queue = []
    queue << OrNode.new(48, 69, 6)
    queue << XorNode.new(27, 48, 3)
    queue << OrNode.new(14, 27, 1)
    queue << AndNode.new(14, 27, 5)
    queue << NotNode.new(14, 48, 9)
    queue << ZeroNode.new(0, 14, 0)
    queue << OneNode.new(0, 14, 2)
    queue << OneNode.new(0, 14, 4)
    queue << OneNode.new(0, 14, 6)
    queue << ZeroNode.new(0, 14, 8)
    result = queue[0].process(queue)
    assert_true(result)
  end
  
  def test_wired_simple
    w = Wired.new
    filename = File.dirname(__FILE__) + "/simple_circuits.txt"
    w.read_lines(filename)
    filename = File.dirname(__FILE__) + "/solved_circuits.txt"
    w.solve_circuits(filename)
  end
  
  def test_wired_complex_second
    w = Wired.new
    filename = File.dirname(__FILE__) + "/complex_circuits_second_0.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "ONAOO01110"
    assert_equal(result, queue.to_s)
    
    filename = File.dirname(__FILE__) + "/complex_circuits_second_1.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "AOXAXAO01101010"
    assert_equal(result, queue.to_s)
    
    filename = File.dirname(__FILE__) + "/complex_circuits_second_2.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "XOANAOXOO0AXAO111001101010"
    assert_equal(result, queue.to_s)
    
    filename = File.dirname(__FILE__) + "/complex_circuits_second_3.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "NAXO1110"
    assert_equal(result, queue.to_s)
    
    filename = File.dirname(__FILE__) + "/complex_circuits_second_4.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "OXOANNAOXAOO0AXAOXO1110011010101110"
    assert_equal(result, queue.to_s)
    
    filename = File.dirname(__FILE__) + "/complex_circuits_second_5.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "OXOANANO1N10AXOA01100111"
    assert_equal(result, queue.to_s)
    
    filename = File.dirname(__FILE__) + "/complex_circuits_second.txt"
    w.read_lines(filename)
    queue = w.fetch_queue(0)
    result = "AOOXXOANOANNAOXAANO1NOO0AXAOXO10AXOA111001101010111001100111".split("")
    assert_equal(result.length, queue.length)
    (0...result.length).each do |i|
      assert_equal(result[i], queue[i].to_s)
    end
    filename = File.dirname(__FILE__) + "/solved_circuits_second.txt"
    w.solve_circuits(filename)
  end
  
  def test_wired_complex
    w = Wired.new
    filename = File.dirname(__FILE__) + "/../lib" + "/complex_circuits.txt"
    w.read_lines(filename)
    filename = File.dirname(__FILE__) + "/../lib" + "/solved_complex_circuits.txt"
    w.solve_circuits(filename)
  end
end
