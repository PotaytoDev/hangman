def list_of_possible_words
  possible_words = File.readlines('google-10000-english-no-swears.txt')
  possible_words.select! do |word|
    word.chomp!
    word.length >= 5 && word.length <= 12
  end
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

def take_player_guess
  print 'Enter your guess: '
  validate_player_guess(gets.chomp.downcase)
end

secret_word = list_of_possible_words.sample
puts secret_word
puts "You entered #{take_player_guess}"
