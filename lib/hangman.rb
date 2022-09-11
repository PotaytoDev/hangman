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
    current_word_progress = Array.new(secret_word.length, '_').join
    player_has_won = false
    incorrect_guesses_left = 6
    number_of_turns_played = 1

    while incorrect_guesses_left.positive?
      puts "\n----------------------------------------------------------------"
      puts "Turn #{number_of_turns_played}"
      number_of_turns_played += 1

      puts "\n"
      puts current_word_progress.chars.join(' ')

      puts "\n\nYou have #{incorrect_guesses_left} incorrect guesses left."

      player_guess = player.make_guess

      previous_word_progress = current_word_progress
      current_word_progress = compare_guess_with_secret_word(player_guess, secret_word, current_word_progress)

      if current_word_progress == previous_word_progress
        incorrect_guesses_left -= 1
      end

      if current_word_progress == secret_word
        player_has_won = true
        break
      end
    end

    puts "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts player_has_won ? 'You win!' : 'You lose!'

    puts "The secret word was #{secret_word}"
  end
end

GameLogic.new.play_game
