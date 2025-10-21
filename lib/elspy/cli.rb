# frozen_string_literal: true

require 'optparse'

module Elspy
  class CLI
    def initialize(args)
      @args = args
      @manager = Manager.new
    end

    def run
      return help if @args.empty?

      command = @args.shift

      case command
      when 'install' then install
      when 'update' then update
      when 'remove' then remove
      when 'run' then run_lsp
      when 'list' then list
      when 'help', '-h', '--help'
        help
      else
        puts "unknown command: #{command}"
        help
        exit 1
      end
    rescue Error => e
      puts "error: #{e.message}"
      exit 1
    end

    private

    def install
      options = { version: :latest }

      parser = OptionParser.new do |opts|
        opts.banner = 'usage: elspy install <RECIPE> [OPTIONS]'

        opts.on('-v', '--version VERSION', 'specific version to install (default: latest)') do |v|
          options[:version] = v
        end

        opts.on('-h', '---help', 'show this message') do
          puts opts
          exit
        end
      end

      parser.parse!(@args)

      if @args.empty?
        warn 'error: recipe name required'
        puts parser
        exit 1
      end

      recipe_name = @args.shift
      @manager.install(recipe_name, version: options[:version])
    end

    def update
      parser = OptionParser.new do |opts|
        opts.banner = 'usage: elspy update <RECIPE>'

        opts.on('-h', '--help', 'show this message') do
          puts opts
          exit
        end
      end

      parser.parse!(@args)

      if @args.empty?
        warn 'error: recipe name required'
        puts parser
        exit 1
      end

      recipe_name = @args.shift
      @manager.update(recipe_name)
    end

    def remove
      parser = OptionParser.new do |opts|
        opts.banner = 'usage: elspy remove <RECIPE>'

        opts.on('-h', '--help', 'show this message') do
          puts opts
          exit
        end
      end

      parser.parse!(@args)

      if @args.empty?
        warn 'error: recipe name required'
        puts parser
        exit 1
      end

      recipe_name = @args.shift
      @manager.remove(recipe_name)
    end

    def run_lsp
      parser = OptionParser.new do |opts|
        opts.banner = 'usage: elspy run <RECIPE> [ARGS]'

        opts.on('-h', '--help', 'show this message') do
          puts opts
          exit
        end
      end

      parser.parse!(@args)

      if @args.empty?
        warn 'error: recipe name required'
        puts parser
        exit 1
      end

      recipe_name = @args.shift
      remaining = @args

      @manager.run(recipe_name, *remaining)
    end

    def list
      parser = OptionParser.new do |opts|
        opts.banner = 'usage: elspy list'

        opts.on('-h', '--help', 'show this message') do
          puts opts
          exit
        end
      end

      parser.parse!(@args)

      @manager.list
    end

    def help
      puts <<~HELP
        usage: elspy <COMMAND> [OPTIONS]

        commands:
          install <RECIPE>      install a tool
          update <RECIPE>       update an installed tool
          remove <RECIPE>       remove an installed tool
          run <RECIPE> [ARGS]   run an installed tool
          list                  list installed tools
          help                  show this message

        examples:
          elspy install typescript-language-server
          elspy update lua-ls
          elspy run typescript-language-server --stdio

        for more info on a command, run:
          elspy <COMMAND> --help
      HELP
    end
  end
end
