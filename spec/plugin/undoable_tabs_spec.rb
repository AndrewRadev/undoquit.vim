require 'spec_helper'

describe "Undoquit" do
  before :each do
    write_file 'one.txt', 'one'
    write_file 'two.txt', 'two'
    write_file 'three.txt', 'three'
    write_file 'four.txt', 'four'
    write_file 'five.txt', 'five'

    vim.command :tabonly
    vim.command :only
  end

  specify "restoring all windows in the same tab" do
    vim.edit 'one.txt'
    vim.command 'rightbelow split two.txt'
    vim.command 'rightbelow split three.txt'

    vim.command :quit
    vim.command :quit

    # initial state after quitting
    expect(windows).to eq ['one.txt']

    # restore both windows
    vim.command 'UndoquitTab'
    expect(windows).to eq ['one.txt', 'two.txt', 'three.txt']
  end

  specify "restoring all windows in another tab" do
    vim.edit 'one.txt'
    vim.command 'rightbelow split two.txt'
    vim.command 'tabnew three.txt'
    vim.command 'rightbelow split four.txt'

    vim.command :quit
    vim.command :quit

    # initial state after quitting
    expect(windows).to eq ['one.txt', 'two.txt']
    expect(tab_pages.count).to eq(1)

    # restore separate tab
    vim.command 'UndoquitTab'
    expect(windows).to eq ['three.txt', 'four.txt']
    expect(tab_pages.count).to eq(2)
  end

  specify "with the custom :UndoableTabclose command" do
    vim.edit 'one.txt'
    vim.command 'rightbelow split two.txt'
    vim.command 'tabnew three.txt'
    vim.command 'rightbelow split four.txt'
    vim.command 'tabnew five.txt'

    vim.command '2tabnext'
    vim.command 'UndoableTabclose'
    vim.command 'UndoableTabclose'

    # initial state after quitting
    expect(tab_pages.count).to eq(1)
    expect(windows).to eq ['one.txt', 'two.txt']

    vim.command 'UndoquitTab'
    expect(tab_pages.count).to eq(2)
    expect(windows).to eq ['five.txt']

    vim.command 'UndoquitTab'
    expect(tab_pages.count).to eq(3)
    vim.command '2tabnext'
    expect(windows).to eq ['three.txt', 'four.txt']
    vim.command '3tabnext'
    expect(windows).to eq ['five.txt']
  end

  describe ":UndoableTabclose" do
    before :each do
      vim.edit 'one.txt'
      vim.command 'tabnew two.txt'
      vim.command 'tabnew three.txt'
      vim.command 'tabnew four.txt'
      vim.command 'tabnew five.txt'
    end

    specify "closes tab pages specified by a prefix" do
      pending "Broken on TravisCI due to old Vim version" if ENV['TRAVIS_CI']

      expect(tab_pages).to eq ['one.txt', 'two.txt', 'three.txt', 'four.txt', 'five.txt']

      vim.command '1tabnext'
      vim.command 'UndoableTabclose'
      expect(tab_pages).to eq ['two.txt', 'three.txt', 'four.txt', 'five.txt']

      vim.command '3UndoableTabclose'
      expect(tab_pages).to eq ['two.txt', 'three.txt', 'five.txt']

      vim.command '1tabnext'
      vim.command '+UndoableTabclose'
      expect(tab_pages).to eq ['two.txt', 'five.txt']

      vim.command '1tabnext'
      vim.command '$UndoableTabclose'
      expect(tab_pages).to eq ['two.txt']
    end

    specify "closes tab pages specified by a suffix" do
      pending "Broken on TravisCI due to old Vim version" if ENV['TRAVIS_CI']

      expect(tab_pages).to eq ['one.txt', 'two.txt', 'three.txt', 'four.txt', 'five.txt']

      vim.command '1tabnext'
      vim.command 'UndoableTabclose $'
      expect(tab_pages).to eq ['one.txt', 'two.txt', 'three.txt', 'four.txt']

      vim.command '$tabnext'
      vim.command 'UndoableTabclose -2'
      expect(tab_pages).to eq ['one.txt', 'three.txt', 'four.txt']
    end
  end
end
