# elspy

**elspy** (pronounced _LSP_) is a recipe-based tool for managing language servers, formatters, and potentially other dev tools in one place.

## Why?

Multiple reasons. I use multiple editors for different things, and got tired of:
- each editor installing its own copy of the same language server, essentially filling up my disk with duplicate installations of rust-analyzer and friends
- [paths do not work correctly with mason.nvim](https://github.com/mason-org/mason.nvim/issues/1315)
- reconfiguring the same tooling over and over for each editor

Also, why not?

## Installation

```bash
gem install elspy
```

## Usage

```bash
# Install a tool
elspy install solargraph

# Update a tool to the latest version
elspy update solargraph

# Remove a tool
elspy remove solargraph

# See what's installed
elspy list

# Run a tool
elspy run solargraph
```

### Editor Configuration

Simply point your editor to the `elspy run` command.

<details open>
    <summary>Neovim Example</summary>

```lua
-- lsp/solargraph.lua
return {
    cmd = { 'elspy', 'run', 'solargraph' },
    filetypes = { 'ruby' }
}
```

</details>

### Writing Recipes

Recipes define how to install and run tools. 

Custom recipes go in `~/.config/elspy/recipes`.

Bundled ones are available in the repository, check the `recipes/` directory for examples.

<details>
    <summary>Example Recipe</summary>

```rb
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
```

</details>
