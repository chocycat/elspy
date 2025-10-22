# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'time'

module Elspy
  class Recipe
    attr_reader :name, :version, :install_dir

    def initialize(name, &)
      @name = name
      @dependencies = []

      @install_dir = File.join(DOWNLOADS_DIR, name)

      @download_block = nil
      @run_block = nil
      @binary_path = nil

      instance_eval(&) if block_given?
    end

    def download(version: :latest, &block)
      @version = version
      @download_block = block
    end

    def binary(path)
      @binary_path = path
    end

    def binary_path
      File.join(@install_dir, @binary_path)
    end

    def run(&block)
      @run_block = block
    end

    def depends_on(*commands, any: nil, all: nil)
      @dependencies << { type: :any, commands: Array(any) } if any
      @dependencies << { type: :all, commands: Array(all) } if all

      return unless commands.any?

      @dependencies << { type: :all, commands: }
    end

    def check_dependencies!
      @dependencies.each do |dep|
        case dep[:type]
        when :all
          missing = dep[:commands].reject { |cmd| command_exists?(cmd) }
          unless missing.empty?
            raise Error, "Missing required dependencies: #{missing.join(', ')}\n" \
                         'Please install them to continue.'
          end
        when :any
          found = dep[:commands].any? { |cmd| command_exists?(cmd) }
          unless found
            raise Error, "Missing dependencies: need at least one of [#{dep[:commands].join(', ')}]\n" \
                         'Please install one of them to continue.'
          end
        end
      end
    end

    def exec_download(version: :latest)
      @version = version
      instance_exec(version:, &@download_block)
    end

    def exec_run(*args)
      instance_exec(*args, &@run_block)
    end

    def remove
      return unless Dir.exist?(@install_dir)

      FileUtils.rm_rf(@install_dir)
      puts "Removed: #{@install_dir}"
    end

    def gem_install(gem_name, version = :latest)
      FileUtils.mkdir_p(@install_dir)

      gem_version = version == :latest ? [] : ['-v', version.to_s]

      system(
        'gem', 'install', gem_name,
        *gem_version,
        '--install-dir', @install_dir,
        '--bindir', File.join(@install_dir, 'bin'),
        '--no-document',
        exception: true
      )

      version = if version == :latest
                  require 'rubygems'

                  specs_dir = File.join(@install_dir, 'specifications')
                  gemspec_files = Dir.glob(File.join(specs_dir, "#{gem_name}-*.gemspec"))

                  if gemspec_files.any?
                    spec = Gem::Specification.load(gemspec_files.first)
                    spec.version.to_s
                  else
                    'unknown'
                  end
                else
                  version.to_s
                end

      save_metadata(version:)
    end

    def node_install(package, version = :latest, package_manager: nil)
      FileUtils.mkdir_p(@install_dir)

      package_manager ||= node_pm
      package_arg = version == :latest ? package : "#{package}@#{version}"

      Dir.chdir(@install_dir) do
        case package_manager
        when :pnpm
          system('pnpm', 'add', package_arg, exception: true)
        when :npm
          system('npm', 'install', package_arg, '--no-save', '--prefix', '.', exception: true)
        end
      end

      version = if version == :latest
                  package_json = File.join(@install_dir, 'node_modules', package, 'package.json')
                  if File.exist?(package_json)
                    JSON.parse(File.read(package_json))['version']
                  else
                    'unknown'
                  end
                else
                  version.to_s
                end

      save_metadata(version:)
    end

    def node_pm
      return :pnpm if command_exists? 'pnpm'
      return :npm if command_exists? 'npm'

      raise Error, 'npm or pnpm is not in PATH'
    end

    def command_exists?(cmd)
      system("which #{cmd} > /dev/null 2>&1")
    end

    def save_metadata(version:, **extra)
      metadata = {
        name: @name,
        version: version,
        installed_at: Time.now.iso8601
      }.merge(extra)

      File.write(metadata_path, JSON.pretty_generate(metadata))
    end

    def load_metadata
      return nil unless File.exist?(metadata_path)

      JSON.parse(File.read(metadata_path), symbolize_names: true)
    end

    def metadata_path
      File.join(@install_dir, '.medatada.json')
    end
  end

  def self.recipe(name, &)
    Recipe.new(name, &)
  end
end
