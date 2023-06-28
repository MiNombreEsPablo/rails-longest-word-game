# frozen_string_literal: true

require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = new_letters
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
    @result = result(@word, @letters)
  end

  private

  def new_letters
    letters = []
    10.times do
      letters << ('A'..'Z').to_a.sample
    end
    letters
  end

  def result(word, letters)
    score = 0
    if word_in_grid(word, letters)
      # word can be built with given letters
      attributes = word_validation(word)
      if attributes['found']
        # word exists in API
        message = "<strong>Congratulations!</strong> #{word.upcase} is a valid English word!"
        score = scrabble_score(word)
      else
        # word does not exist in API
        message = "Sorry but #{word.upcase} does not seem to be a valid English word..."
      end
    else
      # word can not be built with given letters
      message = "Sorry but <strong>#{word.upcase}</strong> can't be built out of #{letters.gsub(' ', ', ')}"
    end

    { message:, score: }
  end

  def word_validation(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_serialized = URI.open(url).read
    JSON.parse(word_serialized)
  end

  def word_in_grid(word, letters)
    # Convert the word and letters arrays to lowercase for case-insensitivity
    word = word.downcase
    letters = letters.split.map(&:downcase)

    # Convert the letters array to a hash with default value of 0
    letter_counts = Hash.new(0)
    letters.each { |letter| letter_counts[letter] += 1 }

    # Iterate through each character in the word
    word.chars.each do |char|
      # If the letter count is 0 or negative, the word is not made with the given letters
      return false if letter_counts[char].nil? || letter_counts[char] <= 0

      # Decrement the letter count for each letter used in the word
      letter_counts[char] -= 1
    end

    # If we reach this point, the word is made with the given letters
    true
  end

  def scrabble_score(word)
    score = 0
    letter_values = {
      'a' => 1, 'e' => 1, 'i' => 1, 'o' => 1, 'u' => 1, 'l' => 1, 'n' => 1, 'r' => 1, 's' => 1, 't' => 1,
      'd' => 2, 'g' => 2, 'b' => 3, 'c' => 3, 'm' => 3, 'p' => 3, 'f' => 4, 'h' => 4, 'v' => 4, 'w' => 4, 'y' => 4,
      'k' => 5, 'j' => 8, 'x' => 8, 'q' => 10, 'z' => 10
    }

    word.downcase.each_char do |char|
      score += letter_values[char] if letter_values.key?(char)
    end

    score
  end
end
