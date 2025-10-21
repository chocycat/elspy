# frozen_string_literal: true

require_relative 'elspy/cli'
require_relative 'elspy/manager'
require_relative 'elspy/recipe'

module Elspy
  class Error < StandardError; end

  HOME_DIR = File.expand_path('~/.elspy')
  DOWNLOADS_DIR = File.join(HOME_DIR, 'downloads')
  RECIPES_DIR = File.join(HOME_DIR, 'recipes')
end
