# frozen_string_literal: true

Elspy.recipe 'typescript-language-server' do
  depends_on any: %w[npm pnpm]

  binary 'node_modules/.bin/typescript-language-server'

  download do |version: :latest|
    node_install 'typescript-language-server', version
  end

  run do |args|
    exec binary_path, '--stdio', *args
  end
end
