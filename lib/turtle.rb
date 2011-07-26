#  [#9] Tutle Tracks 
class Turtle
  attr_accessor :board_size, :board, :cursor
  
  def knock_file(file_name, mode)
    file = open(file_name, mode)
    yield(file)
  ensure
    file.close if file
  end

  def read_lines(file_name)
    knock_file(file_name, "r") do |file|
      while line = file.gets
        dispatch(line.split)
      end
    end
  end
  
  def dispatch(args)
    length = args.length
    if length == 1
      @board_size = args.shift.to_i
      @board = Hash.new
      col = row = @board_size/2
      @board[[row, col]] = "X" # center
      @cursor = Cursor.new(row)
    elsif length > 1
      method = args.shift.downcase.to_sym
      self.__send__(method, args)
    end
  end
  
  #        0
  #  7 NW  N  NE 1
  # 6   W  X  E   2
  #  5 SW  S  SE 3
  #        4
  NORTH = 0
  NORTHEAST = 1
  EAST = 2
  SOUTHEAST = 3
  SOUTH = 4
  SOUTHWEST = 5
  WEST = 6
  NORTHWEST = 7
  
  FD_DIFF = {0 => [-1, 0], 1 => [-1, 1], 2 => [0, 1], 3 => [1, 1],
             4 => [1, 0], 5 => [1, -1], 6 => [0, -1], 7 => [-1, -1]}
  
  def fd(args)
    steps = args.shift.to_i
    row_diff = FD_DIFF[@cursor.orientation][0]
    col_diff = FD_DIFF[@cursor.orientation][1]
    (1..steps).each do
      @cursor.row += row_diff
      @cursor.col += col_diff
      @board.merge!({[@cursor.row, @cursor.col] => "X"})
    end
  end
  
  def rt(args)
    angle = args.shift.to_i
    @cursor.orientation += angle / 45
    if @cursor.orientation >= 8
      @cursor.orientation -= 8
    end
  end
  
  def lt(args)
    angle = args.shift.to_i
    @cursor.orientation -= angle / 45
    if @cursor.orientation < 0
      @cursor.orientation += 8
    end
  end
  
  BK_DIFF = {0 => [1, 0], 1 => [1, -1], 2 => [0, -1], 3 => [-1, -1],
             4 => [-1, 0], 5 => [-1, 1], 6 => [0, 1], 7 => [1, 1]}

  def bk(args)
    steps = args.shift.to_i
    row_diff = FD_DIFF[@cursor.orientation][0]
    col_diff = FD_DIFF[@cursor.orientation][1]
    (1..steps).each do
      @cursor.row += row_diff
      @cursor.col += col_diff
      @board.merge!({[@cursor.row, @cursor.col] => "X"})
    end
  end
  
  def repeat(args)
    n = args.shift.to_i # times of repetition
    args = args[1..-2] # delete "[" and "]"
    (1..n).each do
      (0..args.length-2).step(2) do |i|
        dispatch([args[i], args[i+1]])
      end
    end
  end
  
  def show
    (0...@board_size).each do |row|
      line = ""
      (0...@board_size).each do |col|
        if @board.has_key?([row, col])
          line << "X "
        else
          line << ". "
        end
      end
      line.chop!
      print line + "\n"
    end
  end
  
  def write_to_file(filename)
    knock_file(filename, "w") do |file|
      (0...@board_size).each do |row|
      line = ""
      (0...@board_size).each do |col|
        if @board.has_key?([row, col])
          line << "X "
        else
          line << ". "
        end
      end
      line.chop!
      file.puts line
    end
    end
  end
  
  # Cursor saves current position and orientation
  class Cursor
    attr_accessor :row, :col, :orientation

    def initialize(pos)
      @row = @col = pos
      @orientation = 0
    end
  end
end

filename = File.dirname(__FILE__) + '/simple.logo'
t = Turtle.new
t.read_lines(filename)
t.show