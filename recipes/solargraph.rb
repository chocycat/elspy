# frozen_string_literal: true

Elspy.recipe 'solargraph' do
  depends_on 'gem'

  binary 'bin/solargraph'

  download do |version: :latest|
    gem_install 'solargraph', version
  end

  run do |args|
    ENV['GEM_HOME'] = @install_dir
    ENV['GEM_PATH'] = @install_dir

    exec binary_path, 'stdio', *args
  end
end
