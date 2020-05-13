require 'spec_helper'

describe "Undoquit" do
  # TODO (2013-01-14) Slow!
  def tab_pages
    last_tab_page = vim.command("echo tabpagenr('$')").to_i

    (1 .. last_tab_page).map do |tabnr|
      winnr = vim.command("echo tabpagewinnr(#{tabnr})")
      vim.command("tabnext #{tabnr}")
      vim.command("#{winnr}wincmd w")
      vim.command("echo bufname('%')")
    end
  end

  def windows
    last_window = vim.command("echo winnr('$')").to_i

    (1 .. last_window).map do |winnr|
      vim.command("#{winnr}wincmd w")
      vim.command("echo bufname('%')")
    end
  end

  before :each do
    write_file 'one.txt', 'one'
    write_file 'two.txt', 'two'
    write_file 'three.txt', 'three'
    write_file 'four.txt', 'three'
    write_file 'five.txt', 'three'

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

  describe "tabs" do
    before :each do
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

  describe "splits" do
    before :each do
      vim.edit 'one.txt'
      vim.command 'rightbelow split two.txt'
      vim.command 'rightbelow split three.txt'
    end

    specify "simple case" do
      # close windows 3 and 1
      vim.command '3wincmd w'
      vim.command :quit
      vim.command '1wincmd w'
      vim.command :quit

      # initial state after quitting
      expect(windows).to eq ['two.txt']

      # restore window 1
      vim.command 'Undoquit'
      expect(windows).to eq ['one.txt', 'two.txt']

      # restore window 3
      vim.command 'Undoquit'
      expect(windows).to eq ['one.txt', 'two.txt', 'three.txt']
    end

    specify "quit and undo top window" do
      # close window 1
      vim.command '1wincmd w'
      vim.command :quit

      # initial state after quitting
      expect(windows).to eq ['two.txt', 'three.txt']

      # restore window 1
      vim.command 'Undoquit'
      expect(windows).to eq ['one.txt', 'two.txt', 'three.txt']
    end
  end

  describe "restoring an entire tab" do
    specify "the same tab" do
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

    specify "another tab" do
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
  end
end
