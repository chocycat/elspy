# frozen_string_literal: true

require 'fileutils'

module Elspy
  class Manager
    def initialize
      setup_directories
    end

    def install(recipe_name, version: :latest)
      recipe = load_recipe recipe_name
      recipe.check_dependencies!
      recipe.exec_download(version:)
    end

    def update(recipe_name)
      recipe = load_recipe recipe_name
      recipe.check_dependencies!
      recipe.exec_download(version: :latest)
    end

    def remove(recipe_name)
      recipe = load_recipe recipe_name

      print "Remove #{recipe_name}? (y/N): "
      return unless $stdin.gets.chomp.downcase == 'y'

      begin
        puts "Successfully removed #{recipe_name}" if recipe.remove
      rescue Error => e
        puts "Failed to remove #{recipe_name}: #{e}"
      end
    end

    def run(recipe_name, *args)
      recipe = load_recipe recipe_name
      recipe.exec_run(*args)
    end

    def list
      installed = Dir.glob(File.join(DOWNLOADS_DIR, '*'))
                     .select { |path| Dir.exist? path }
                     .map { |path| File.basename path }

      if installed.empty?
        puts 'No tools installed'
        return
      end

      puts 'Installed tools:'

      installed.sort.each do |n|
        recipe = load_recipe n
        metadata = recipe.load_metadata

        if metadata.nil?
          puts "  #{n.ljust(30)} unknown"
        else
          metadata => { version:, installed_at: }
          timestamp = Time.parse(installed_at).strftime('%Y-%m-%d')

          puts "  #{n.ljust(30)} #{version.ljust(15)} (installed #{timestamp})"
        end
      rescue StandardError
        next
      end
    rescue StandardError => e
      warn "Error listing tools: #{e.message}"
    end

    private

    def setup_directories
      [HOME_DIR, DOWNLOADS_DIR, RECIPES_DIR].each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def load_recipe(name)
      recipe = find_recipe(name)
      raise Error, "Recipe '#{name}' not found" unless recipe

      eval(File.read(recipe), binding, recipe) # rubocop:disable Security/Eval
    end

    def find_recipe(name)
      # recipes the user has on their computer
      user_recipe = File.join(RECIPES_DIR, "#{name}.rb")
      return user_recipe if File.exist?(user_recipe)

      # bundled with the gem
      bundled_recipe = File.join(__dir__, '../../recipes', "#{name}.rb")
      return bundled_recipe if File.exist?(bundled_recipe)

      nil
    end
  end
end
