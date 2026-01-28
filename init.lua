--misc options
vim.g.have_nerd_font = true
vim.opt.ignorecase = true
vim.opt.splitright = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.tabstop = 4
vim.opt.scrolloff = 8 -- min screen lines to keep above and below cursor
vim.opt.clipboard = 'unnamedplus'
vim.opt.numberwidth = 7
vim.opt.mouse = "nvi"
vim.opt.smartcase = true
vim.opt.breakindent = true --[[Every wrapped line will continue visually indented
(same amount of space as the beginning of that line),
thus preserving horizontal blocks of text. ]] --
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { callback = function() vim.cmd("checktime") end })
vim.opt.confirm = true
vim.opt.undofile = true

--tab and indent stuff
vim.opt.tabstop = 4
vim.opt.softtabstop = 4 
vim.opt.shiftwidth = 4 
vim.opt.expandtab = true 
vim.cmd('filetype plugin indent on')
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cinoptions = "(0"

require("config.lazy")
vim.cmd [[colorscheme vscode]]

-- greatest remap ever
vim.keymap.set("x", "<leader>p", "\"_dP")

--neotree
vim.keymap.set("n", "\\", ":Neotree toggle<CR>", { noremap = true, silent = true }) 

--window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

--highlight when yanking text
--'yap' in normal mode
--see ':help vim.highlight.on_yank()'
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

--highlight go away when pressing escape in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>v", "<cmd>vsp<CR>")

require("config.lsp.lsp_init")

-- make related stuff

vim.opt.switchbuf = {"useopen", "usetab", "uselast"} -- try to prevent new buffers being opened by quickfix list

vim.keymap.set("n", "<leader>b", function()
    vim.cmd('wall')
    local pos = vim.fn.getpos('.')
    vim.cmd('silent make')

    local qflist = vim.fn.getqflist()

    local valid_errors = {}
    for _, item in ipairs(qflist) do
        if item.bufnr > 0 and item.lnum > 0 then
            table.insert(valid_errors, item)
        end
    end

    if #valid_errors > 0 then
        vim.cmd('copen')
        vim.cmd('cc')
    else
        vim.cmd('cclose')
        vim.fn.setpos('.', pos)
    end
end)

vim.keymap.set("n", "<leader>qf", function()
    local qf_open = false
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            qf_open = 1
            break
        end
    end
    if qf_open then
        vim.cmd("cclose")
    else
        -- Save all open buffers
        vim.cmd("wall")

        -- Close all other windows (leave only one)
        vim.cmd("only")

        -- Open quickfix list and jump to first entry
        vim.cmd("copen")
        if vim.fn.getqflist({ size = 0 }).size > 0 then
            vim.cmd("cc")  -- Jump to first quickfix entry
        else
            print("Quickfix list is empty.")
            return
        end
    end
end)

vim.api.nvim_create_autocmd({"BufEnter","BufWinEnter"}, {
  pattern = {"*.c","*.cpp","*.h","*.hpp"},
  callback = function(args)

    vim.opt_local.makeprg = "cmd /c build.bat"
    if not vim.env.NVIM_FORCE_TEE then
        vim.opt_local.shellpipe = ">%s 2>&1"
    end

    -- replaces the stock errorformat
    local efm = table.concat({
      -- clang-style with parentheses and column
      [[%E%f(%l\,%c):\ error:\ %m]],
      [[%W%f(%l\,%c):\ warning:\ %m]],
      [[%I%f(%l\,%c):\ note:\ %m]],

      -- same without column (just in case)
      [[%E%f(%l):\ error:\ %m]],
      [[%W%f(%l):\ warning:\ %m]],
      [[%I%f(%l):\ note:\ %m]],

      -- include stack lines: "In file included from foo.c:2:"
      [[%CIn\ file\ included\ from\ %f:%l:]],
      -- occasional “from …:line:col:” continuation
      [[%C\ \ \ \ from\ %f:%l:%c:]],
    }, ",")

    vim.opt_local.errorformat = efm
  end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"c", "cpp"},
    callback = function()
        vim.opt_local.cindent = true
    end,
})

-- Force one-buffer-per-file by real path
-- local api, fn, uv = vim.api, vim.fn, vim.loop
--
-- local function realpath(p)
--   if p == "" then return "" end
--   return uv.fs_realpath(p) or fn.fnamemodify(p, ":p")
-- end
--
-- api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
--   callback = function(args)
--     local target = realpath(args.file or fn.bufname(args.buf))
--     if target == "" then return end
--     for _, b in ipairs(api.nvim_list_bufs()) do
--       if b ~= args.buf and api.nvim_buf_is_loaded(b) and fn.buflisted(b) == 1 then
--         local name = fn.bufname(b)
--         if name ~= "" and realpath(name) == target then
--           vim.notify(
--             ("Duplicate suppressed; jumping to buffer #%d (%s)")
--               :format(b, fn.fnamemodify(name, ":.")),
--             vim.log.levels.WARN, { title = "Duplicate buffer detected" }
--           )
--           vim.schedule(function()
--             vim.cmd("keepalt keepjumps buffer " .. b)
--           end)
--           return
--         end
--       end
--     end
--   end,
-- })
-- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--     pattern = {"*.go"},
--     callback = function()
--         vim.opt.makeprg = "go build"
--     end,
-- })
--
--
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     pattern = "*.go",
--     callback = function()
--         vim.fn.setqflist({}) -- clear old list
--         vim.fn.system("go vet ./...")
--
--         -- Parse output and fill quickfix
--         vim.cmd("cgetexpr systemlist('go vet ./...')")
--
--         -- open QF if errors
--         if vim.fn.getqflist({ size = 0 }).size > 0 then
--             vim.cmd("copen")
--             vim.cmd("cc 1")
--             pcall(vim.treesitter.stop)
--             pcall(vim.treesitter.start)
--         else
--             vim.cmd("cclose")
--         end
--     end,
-- })
--
--
