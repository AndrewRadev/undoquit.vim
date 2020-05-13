require 'vimrunner'
require 'vimrunner/rspec'
require_relative './support/vim'

plugin_path = File.expand_path('.')

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  config.start_vim do
    vim = Vimrunner.start_gvim

    vim.add_plugin(plugin_path, 'plugin/undoquit.vim')
    vim
  end
end

RSpec.configure do |config|
  tmp_dir = File.expand_path(File.dirname(__FILE__) + '/../tmp')

  config.include Support::Vim
  config.example_status_persistence_file_path = tmp_dir + '/examples.txt'
end
