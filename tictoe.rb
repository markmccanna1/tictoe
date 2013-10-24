class Player

  attr_reader :moves,:symbol

  def initialize(symbol, board)
    @moves = []
    @symbol = symbol
    @board = board
  end

  def take_turn(turn,open_cells)
    new_move = false
    until new_move
      input = parse_input
      position = cords_to_position(input)
      new_move = open_cells.include?(position)
    end
    @moves << position
    @board.change_board(@symbol, position)
  end

  private

  def parse_input
        puts "please enter your move's cords (down x, over y) seperated by a space"
        valid = nil
        until valid 
          input = gets.chomp
          match = /(\d){1} (\d){1}/.match(input)
            if match != nil 
              valid = true 
            else 
              puts "please enter your move's cords (down x, over y) seperated by a space"
            end
        end
      [match[1].to_i, match[2].to_i]
  end


  def cords_to_position(cords)
    position = (cords[0] * 3) + cords[1]
  end

end


class Game

  def initialize
    @board = Board.new
    @paths = [[0, 3, 6],
              [1, 4, 7],
              [2, 5, 8],
              [0, 4, 8],
              [6, 4, 2],
              [0, 1, 2],
              [3, 4, 5],
              [6, 7, 8]]
    @players = []
    player = Player.new("1", @board)
    @players << player
    @players << AI.new("2", player, @board, @paths)
    @turn = 1
    @winner = nil
  end

  def play
    until @winner
      @players.each do |player|
        puts ""
        puts ""
        puts "Turn #{@turn}"
        puts "Player #{player.symbol}'s move"
        puts "here's the current board:"
        @board.print_board
        player.take_turn(@turn,open_cells)
        @turn += 1
        @winner = check_winner(player)
        break if @winner
      end
    end
    @board.print_board
    puts "#{@winner}"
  end


  private

  def check_winner(player)
    @paths.each do |path|
        if path - player.moves == [] 
          return "Player #{player.symbol} Wins!" 
        end
    end
    if open_cells.count == 0
        return "Draw!"
    end
    nil
  end


  def open_cells
   open = []
    @board.data.length.times do |x|
      open << x if @board.data[x] == "0"
    end
    open
  end

end

class Board

  attr_reader :data

  def initialize
    @data = "000000000"
  end

  def change_board(player, position)
    @data[position] = player
  end

  def print_board
    printable_board = "  0 1 2 \n"
    @data.length.times do |i|
      printable_board << "#{i / 3}|" if i % 3 == 0
      printable_board << @data[i] + " "
      printable_board << "\n" if i % 3 == 2
    end  
    puts printable_board
  end
  
end


class AI < Player
  
  def initialize(symbol, opponent, board, paths)
    @symbol = symbol
    @opponent = opponent
    @paths = paths
    @moves = []
    @board = board
    @diagonals = [[0, 4, 8],
                  [6, 4, 2]]
  end

  def take_turn(turn,open_cells)
    if opponent_marked_center
      move = respond_to_center(turn)
    else
      move = take_center(turn)
    end
    @board.change_board(@symbol, move)
    @moves << move
    puts "AI made its move"
  end


  private

  def respond_to_center(turn)
    if turn == 2
      return get_open(corners).sample
    elsif turn == 4
      if opponent_diagonaled
        return get_open(corners).sample
      else
        return play_smart
      end
    else
      return play_smart
    end
  end

  def take_center(turn)
    if turn == 2
      return center
    elsif turn == 4
      if opponent_diagonaled
        return get_open(edges).sample
      else 
        return play_smart
      end
    else
      return play_smart
    end
  end

  def play_smart
    opponent_paths = rank_win_paths(@opponent)
    ai_paths = rank_win_paths(self)
    you_can_win = winnable_path(ai_paths, 1)
    opponent_can_win = winnable_path(opponent_paths, 1)
    if you_can_win
      return you_can_win[0]
    elsif opponent_can_win
      return opponent_can_win[0]
    else
      return winnable_path(ai_paths, 2)[0]
    end
  end

  def winnable_path(paths, turns)
    paths.each do |path, turn_count|
      return path if turn_count == turns 
    end
    nil
  end

  def opponent_diagonaled
    @diagonals.each do |path|
        return true if path - @opponent.moves - @moves == []
    end
    false
  end

  def opponent_marked_center
    return true if @opponent.moves.include? 4
    false
  end

  def possible_win_paths(player)
    enemy_moves = @moves + @opponent.moves
    enemy_moves -= player.moves
    impossible_paths = []
    enemy_moves.each do |move|
      @paths.each do |path|
        impossible_paths << path if path.include?(move)
      end
    end
    @paths - impossible_paths
  end

  def rank_win_paths(player)
    paths = possible_win_paths(player)
    tally_paths = []
    paths.each do |path|
      player.moves.each do |move|
        path = path - [move]
      end
      tally_paths << path
    end
    ranked_paths = {}
    tally_paths.each do |path|
      ranked_paths[path] = path.count
    end
    ranked_paths
  end

  def get_open(cells)
    open = []
    cells.each do |x|
      open << x if @board.data[x] == "0"
    end
    open
  end

  def corners
    corners = [0, 2, 6, 8]
  end

  def edges
    edges = [1, 3, 5, 7]
  end

  def center
    4
  end

  def all
    (0..8).to_a
  end

end


game = Game.new
game.play