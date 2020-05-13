require 'spec_helper'

describe "Basic" do
  before :each do
    write_file 'one.txt', 'one'
    write_file 'two.txt', 'two'

    vim.command :tabonly
    vim.command :only
  end

  it "restores a window in the same tab if only special buffers are present" do
    vim.edit 'one.txt'
    vim.command 'tabnew two.txt'
    vim.command 'copen'
    vim.command 'wincmd k'

    vim.command 'quit' # quit window
    vim.command 'quit' # quit quickfix window
    vim.command 'Undoquit'

    expect(tab_pages).to eq ['one.txt', 'two.txt']
    expect(windows).to eq ['two.txt']
  end

  it "restores a help window" do
    vim.edit 'one.txt'
    vim.command 'help'

    vim.command 'quit' # quit help window
    vim.command 'Undoquit' # restore help window

    expect(tab_pages[0]).to match /\/help\.txt$/
    expect(windows[0]).to match /\/help\.txt$/
  end
end
