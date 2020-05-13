describe "Splits" do
  before :each do
    write_file 'one.txt', 'one'
    write_file 'two.txt', 'two'
    write_file 'three.txt', 'three'

    vim.command :tabonly
    vim.command :only

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
