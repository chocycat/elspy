# frozen_string_literal: true

Elspy.recipe 'lua-language-server' do
  depends_on 'tar'

  binary 'bin/lua-language-server'

  download do |version: :latest|
    version = '3.15.0' if version == :latest

    url = "https://github.com/LuaLS/lua-language-server/releases/download/#{version}/lua-language-server-#{version}-linux-x64.tar.gz"
    archive_path = http_download url
    system 'tar', '-xzf', archive_path, '-C', @install_dir, exception: true

    FileUtils.rm_f archive_path
    FileUtils.chmod(0o755, binary_path)

    save_metadata version:
  end

  run do |args|
    exec binary_path, '--stdio', *args
  end
end
