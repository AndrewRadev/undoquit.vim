require 'spec_helper'

describe "Tabs" do
  before :each do
    write_file 'one.txt', 'one'
    write_file 'two.txt', 'two'
    write_file 'three.txt', 'three'
    write_file 'four.txt', 'four'

    vim.command :tabonly
    vim.command :only

    vim.edit 'one.txt'
    vim.command 'tabnew two.txt'
    vim.command 'tabnew three.txt'
  end

  specify "simple case" do
    # close tabpage 3 and 1
    vim.command :quit
    vim.command :tabfirst
    vim.command :quit

    # initial state after quitting
    expect(tab_pages).to eq ['two.txt']

    # restore tabpage 1
    vim.command 'Undoquit'
    expect(tab_pages).to eq ['one.txt', 'two.txt']

    # restore tabpage 3
    vim.command 'Undoquit'
    expect(tab_pages).to eq ['one.txt', 'two.txt', 'three.txt']
  end

  specify "split in tab" do
    # open and close split in first tab
    vim.command :tabfirst
    vim.command 'rightbelow split four.txt'
    vim.command :quit

    # move away from first tab
    vim.command :tablast

    # restore split in tabpage 1
    vim.command 'Undoquit'

    vim.command :tabfirst
    expect(windows).to eq ['one.txt', 'four.txt']
  end
end
