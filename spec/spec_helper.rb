require 'vimrunner'
require 'vimrunner/rspec'

plugin_path = File.expand_path('.')

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  config.start_vim do
    vim = Vimrunner.start_gvim

    vim.add_plugin(plugin_path, 'plugin/undoquit.vim')
    vim
  end
end
