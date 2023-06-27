# frozen_string_literal: true

class GamesController < ApplicationController

  def new
    @letters = new_letters
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
  end

  private

  def new_letters
    letters = []
    10.times do
      letters << ('A'..'Z').to_a.sample
    end
    letters
  end
end
