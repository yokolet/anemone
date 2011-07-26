# [#10] All Wired Up
class Wired
  def knock_file(file_name, mode)
    file = open(file_name, mode)
    yield(file)
  ensure
    file.close if file
  end

  def read_lines(file_name)
    knock_file(file_name, "r") do |file|
      queue_no = 0
      queue = []
      line_no = 0
      while line = file.gets
        if line.delete(" ").chomp.length == 0
          self.instance_variable_set("@queue_#{queue_no}", queue)
          queue_no += 1
          queue = []
          line_no = 0
          next
        end
        create_queue(line, line_no, queue)
        line_no += 1
      end
      self.instance_variable_set("@queue_#{queue_no}", queue)  # the last tree
    end
  end
  
  def create_queue(line, line_no, queue)
    input = line.split("")
    op_index, parent_index = [], []
    find_index_of_operations(input, op_index, parent_index)
    queue = insert(input, op_index, parent_index, line_no, queue)
  end
  
  def fetch_queue(no)
    self.instance_variable_get("@queue_#{no}")
  end
  
  def find_index_of_operations(input, op_index, parent_index)
    maybe_parent_index = []
    input.each_with_index do |item, index|
      op_index << index if item =~ /[01AOXN]/
      maybe_parent_index << index if item == "|"
    end
    i = 0
    maybe_parent_index.each do |item|
      if i < op_index.length && op_index[i] < item
        parent_index << item
        i += 1
      end
    end
  end
  
  def insert(input, op_index, parent_index, line_no, queue)
    op_index.each do |col|
      case
      when input[col] == "0"
        queue << ZeroNode.new(col, parent_index[op_index.find_index(col)], line_no)
      when input[col] == "1"
        queue << OneNode.new(col, parent_index[op_index.find_index(col)], line_no)
      when input[col] == "A"
        queue << AndNode.new(col, parent_index[op_index.find_index(col)], line_no)
      when input[col] == "O"
        queue << OrNode.new(col, parent_index[op_index.find_index(col)], line_no)
      when input[col] == "X"
        queue << XorNode.new(col, parent_index[op_index.find_index(col)], line_no)
      when input[col] == "N"
        queue << NotNode.new(col, parent_index[op_index.find_index(col)], line_no)
      end
      heapify(queue)
    end
  end
  
  # pops up to a right position
  def heapify(queue)
    (queue.length - 1).downto(1) do |i|
      if queue[i].value > queue[i-1].value
        queue[i], queue[i-1] = queue[i-1], queue[i]
      else
        break
      end
    end
  end
  
  # depth first search
  def solve_circuits(filename)
    knock_file(filename, "w") do |file|
      no = 0
      while (queue = self.instance_variable_get("@queue_#{no}"))
        result = queue[0].process(queue)
        if result
          file.puts("on")
        else
          file.puts("off")
        end
        no += 1
      end
    end
  end
end

class Node
  # holds column position as a node value, left most should be a root
  attr_reader :value, :parent_value, :line_no
  attr_accessor :state, :left, :right
  
  def initialize(v, p, l)
    @value = v
    @parent_value = p
    @line_no = l
    @state = "undiscovered"
  end
  
  def <=>(other)
    if @value < other.value
      return -1
    elsif @value == other.value
      return 0
    else
      return 1
    end
  end
  
  def process(queue)
    @left = find_child(queue, "left") if @left == nil
    @left_value = @left.process(queue)
    @right = find_child(queue, "right") if @right == nil
    @right_value = @right.process(queue)
    @state = "processed"
    return eval()
  end
  
  def find_child(queue, l_or_r)
    index = queue.find_index {|item| item === self}  # find index of myself
    maybe_children = []
    (index...queue.length).each do |i|               # child must be in later index
      if @value == queue[i].parent_value &&
          queue[i].state != "discovered" && queue[i].state != "processed" then
        maybe_children << queue[i]
      end
    end
    child = guess_who(maybe_children, l_or_r)
    child.state = "discovered"
    return child
  end
  
  def guess_who(maybe_children, l_or_r)
    min = 100000
    child = nil
    maybe_children.each do |item|
      case l_or_r
      when "left"
        if @line_no > item.line_no && (distance = (@line_no - item.line_no).abs) < min
          min = distance
          child = item
        end
      when "right"
        if @line_no < item.line_no && (distance = (@line_no - item.line_no).abs) < min
          min = distance
          child = item
        end
      end
    end
    child
  end
  
  def to_s
    nil
  end
end

class ZeroNode < Node
  def process(queue)
    @state = "processed"
    return false
  end
  
  def to_s
    "0"
  end
end

class OneNode < Node
  def process(queue)
    @state = "processed"
    return true
  end
  
  def to_s
    "1"
  end
end

class AndNode < Node
  def eval()
    @left_value & @right_value
  end
  
  def to_s
    "A"
  end
end

class OrNode < Node
  def eval()
    @left_value | @right_value
  end
  
  def to_s
    "O"
  end
end

class XorNode < Node
  def eval()
    @left_value ^ @right_value
  end
  
  def to_s
    "X"
  end
end

class NotNode < Node
  def process(queue)
    @left = find_child(queue, "left") if @left == nil
    @left_value = @left.process(queue)
    @state = "processed"
    return eval()
  end
  
  def eval()
    !@left_value
  end

  def to_s
    "N"
  end
end