local servers = {
	clangd = {
		cmd = { "clangd",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--function-arg-placeholders=false",
        },
		filetypes = { "c", "cpp" },
        root_markers = { ".git", "main.c", "main.cpp", ".clangd" }
	},
	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
        root_markers = { ".git", "main.py", "pyproject.toml" },
        settings = {
            python = {
                analysis = {
                    useLibraryCodeForTypes = true,
                },
            },
        },
	},
}

for name, config in pairs(servers) do
	vim.lsp.config(name, config)
	vim.lsp.enable(name)
end

vim.diagnostic.config({
    virtual_text = false,
    signs = false,
    underline = false,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded",
    }
)

vim.keymap.set('n', 'p', 'p`[v`]=', { desc = 'Paste and indent' })
vim.keymap.set('n', 'P', 'P`[v`]=', { desc = 'Paste before and indent' })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user.lsp", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        local function setkeymap(mode, keys, called_function)
            vim.keymap.set(mode, keys, called_function, { buffer = bufnr })
        end

        setkeymap('n', 'gd', vim.lsp.buf.definition)
        setkeymap('n', 'gr', vim.lsp.buf.references)
        setkeymap('n', '<leader>rn', vim.lsp.buf.rename)
        setkeymap('n', 'K', function()
            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

            vim.lsp.buf_request(bufnr, 'textDocument/definition', params, function(err, result)
                if err or not result or vim.tbl_isempty(result) then
                    vim.lsp.buf.hover()
                    return
                end

                local target = result[1] or result
                local target_bufnr = vim.uri_to_bufnr(target.uri)
                vim.fn.bufload(target_bufnr)

                local start_line = target.range.start.line
                local lines = vim.api.nvim_buf_get_lines(target_bufnr, start_line, start_line + 15, false)

                -- Find the closing brace to show complete struct
                local end_line = start_line + 15
                for i, line in ipairs(lines) do
                    if line:match("^%s*}") then
                        end_line = start_line + i
                        break
                    end
                end

                lines = vim.api.nvim_buf_get_lines(target_bufnr, start_line, end_line, false)

                local float_bufnr, float_win = vim.lsp.util.open_floating_preview(lines, 'cpp', {
                    border = 'rounded',
                    max_width = 80,
                    max_height = 30,
                })

                -- Enable treesitter highlighting if available
                pcall(function()
                    vim.treesitter.start(float_bufnr, 'cpp')
                end)
            end)
        end)
    end
})



