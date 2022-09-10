def list_of_possible_words
  possible_words = File.readlines('google-10000-english-no-swears.txt')
  possible_words.select! do |word|
    word.chomp!
    word.length >= 5 && word.length <= 12
  end
end

secret_word = list_of_possible_words.sample
puts secret_word
