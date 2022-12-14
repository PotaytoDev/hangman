require 'json'

class Player
  attr_reader :player_guess

  def initialize
    @player_guess = nil
  end

  def guess_has_only_letters?(player_guess)
    player_guess.match(/^[a-z]+$/)
  end

  def validate_player_guess(player_guess)
    until guess_has_only_letters?(player_guess) || player_guess == '0'
      puts 'Invalid input. Please enter only letters in your guess or 0 to save your game.'
      print 'Enter your guess: '
      player_guess = gets.chomp.downcase
    end

    player_guess
  end

  def make_guess
    print "\n\nEnter your guess or 0 to save the game: "
    @player_guess = validate_player_guess(gets.chomp.downcase)
  end
end

class GameLogic
  def reset_game
    @secret_word = list_of_possible_words.sample
    @current_word_progress = Array.new(@secret_word.length, '_').join
    @player_has_won = false
    @incorrect_guesses_left = 6
    @number_of_turns_played = 1
    @incorrect_letters_guessed = []
    @game_was_saved = false
  end

  def list_of_possible_words
    possible_words = File.readlines('google-10000-english-no-swears.txt')
    possible_words.select! do |word|
      word.chomp!
      word.length >= 5 && word.length <= 12
    end
  end

  def compare_guess_with_secret_word(player_guess, secret_word, current_word_progress)
    secret_word = secret_word.chars
    current_word_progress = current_word_progress.chars

    if player_guess.length == 1 && secret_word.include?(player_guess)
      secret_word.each_with_index do |letter, index|
        if letter == player_guess
          current_word_progress[index] = letter
        end
      end
    else
      if player_guess == secret_word.join
        current_word_progress = secret_word
      end
    end

    current_word_progress.join
  end

  def to_json
    hash = {}
    instance_variables.each do |variable|
      hash[variable] = instance_variable_get(variable)
    end
    hash.to_json
  end

  def from_json(json_string)
    JSON.parse(json_string)
  end

  def save_game
    loop do
      print "\nEnter name for your save file (only letters and digits are allowed): "
      save_file_name = gets.chomp

      # Only allow letters and digits for the save file name
      if save_file_name.match(/^[A-Za-z\d]+$/)
        @game_was_saved = true

        save_file_name += '.json'

        File.open(save_file_name, 'w') do |file|
          file.puts to_json
        end

        break
      else
        puts 'Invalid input. Enter only letters and digits for the save file name.'
      end
    end
  end

  def load_game(save_file)
    json_string = File.read(save_file)
    loaded_save_file = from_json(json_string)

    instance_variables.each do |variable|
      instance_variable_set(variable, loaded_save_file[variable.to_s])
    end
  end

  def play_again?
    puts "\n\nPlay again? (Y/N)"

    loop do
      case gets.chomp.downcase
      when 'y', 'yes'
        return true
      when 'n', 'no'
        return false
      else
        puts 'Invalid input. Please enter y for yes and n for no.'
      end
    end
  end

  def display_load_game_menu(saved_games)
    puts "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts "\nHere are your saved games:\n\n"
    saved_games.each_with_index do |save_file, index|
      puts "#{index + 1}) \"#{save_file.split('.').first}\""
    end

    print "\n\nEnter the number of the save file you want to load,\n" \
          "or type 'exit' to return to main menu: "
  end

  def game_was_loaded?
    saved_games = Dir.glob('*.json')

    loop do
      display_load_game_menu(saved_games)
      choice = gets.chomp

      return false if choice == 'exit'

      choice = choice.to_i - 1

      if choice >= 0 && choice < saved_games.length
        load_game(saved_games.at(choice))
        puts "\nLoading game..."
        sleep(3)
        return true
      else
        puts "\nInvalid input. Please enter one of the choices available."
        sleep(2)
      end
    end
  end

  def display_menu
    returned_from_load_game_menu = false

    loop do
      puts "\n\n========================="
      puts '   Welcome to Hangman!!'
      puts '========================='

      puts "\n\n1) Start new game"
      puts '2) Load game'

      loop do
        print "\nEnter your choice: "

        case gets.chomp
        when '1'
          reset_game
          play_game
          break
        when '2'
          reset_game

          # Display load game menu unless there are no saved games
          if Dir.glob('*.json').empty?
            puts 'There are no saved games. Please start a new game.'
            redo
          else
            if game_was_loaded?
              play_game
            else
              returned_from_load_game_menu = true
            end
          end

          break
        else
          puts 'Invalid input. Please enter either 1 or 2.'
        end
      end

      if returned_from_load_game_menu
        returned_from_load_game_menu = false
        redo
      end

      unless play_again?
        puts "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts 'Game Over'
        puts "\nSee you next time!"
        break
      end
    end
  end

  def play_game
    player = Player.new

    while @incorrect_guesses_left.positive?
      puts "\n----------------------------------------------------------------"
      puts "Turn #{@number_of_turns_played}"

      puts "\n"
      puts @current_word_progress.chars.join(' ')

      unless @incorrect_letters_guessed.empty?
        puts "\n\nIncorrect letters: #{@incorrect_letters_guessed.join(', ')}"
      end

      puts "\nYou have #{@incorrect_guesses_left} incorrect guesses left."

      player_guess = player.make_guess

      if player_guess == '0'
        save_game
        puts "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "\nGame saved!"

        loop do
          puts "\nWould you like to quit? (Y/N)"

          case gets.chomp.downcase
          when 'y', 'yes'
            return
          when 'n', 'no'
            break
          else
            puts 'Invalid input. Please enter y for yes and n for no.'
          end
        end

        redo
      end

      previous_word_progress = @current_word_progress
      @current_word_progress = compare_guess_with_secret_word(player_guess, @secret_word, @current_word_progress)

      if @current_word_progress == previous_word_progress
        @incorrect_guesses_left -= 1

        if player_guess.length == 1
          unless @incorrect_letters_guessed.include?(player_guess) || @secret_word.include?(player_guess)
            @incorrect_letters_guessed.push(player_guess)
          end
        end
      end

      if @current_word_progress == @secret_word
        @player_has_won = true
        break
      end

      @number_of_turns_played += 1
    end

    puts "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
    puts @player_has_won ? 'You win!' : 'You lose!'
    puts "The secret word was \"#{@secret_word}\"" unless @game_was_saved && !@player_has_won
    puts "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  end
end

GameLogic.new.display_menu
