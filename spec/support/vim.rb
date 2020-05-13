module Support
  module Vim
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
  end
end
