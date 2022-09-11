class Player
  attr_reader :player_guess

  def initialize
    @player_guess = nil
  end

  def guess_has_only_letters?(player_guess)
    player_guess.match(/^[a-z]+$/)
  end

  def validate_player_guess(player_guess)
    until guess_has_only_letters?(player_guess)
      puts 'Invalid input. Please enter only letters in your guess.'
      print 'Enter your guess: '
      player_guess = gets.chomp.downcase
    end

    player_guess
  end

  def make_guess
    print "\n\nEnter your guess: "
    @player_guess = validate_player_guess(gets.chomp.downcase)
  end
end

class GameLogic
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

  def play_game
    player = Player.new
    secret_word = list_of_possible_words.sample
    puts secret_word
    current_word_progress = Array.new(secret_word.length, '_').join
    puts current_word_progress.chars.join(' ')

    player_guess = player.make_guess
    current_word_progress = compare_guess_with_secret_word(player_guess, secret_word, current_word_progress)
    puts ''
    puts current_word_progress.chars.join(' ')
  end
end

GameLogic.new.play_game
