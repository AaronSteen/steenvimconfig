return {
    "nvim-telescope/telescope.nvim", tag = "0.1.8",
    dependencies = { 
        "nvim-lua/plenary.nvim",
        'nvim-telescope/telescope-ui-select.nvim',
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
    },
    config = function()
        require('telescope').setup {
            pickers = {
                buffers = {
                    mappings = {
                        i = {
                                ["<C-d>"] = "delete_buffer",
                            }
                    }
                }
            }, 
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- pcall = "protected call"; can catch error and not crash nvim
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch [G]rep' })
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sr', builtin.registers, { desc = '[S]earch [R]egisters' })
        vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })

        vim.keymap.set( 'n', '<leader>en', function()
            builtin.find_files { cwd = vim.fn.stdpath('config') }
        end, { desc = '[E]dit [N]eovim config' } )

        vim.keymap.set( 'n', '<leader>swf', function()
            builtin.find_files { cwd = [[W:\]] }
        end, { desc = '[S]earch [W]ork [F]iles' } )

        vim.keymap.set( 'n', '<leader>swg', function()
            builtin.live_grep { cwd = [[W:\]] }
        end, { desc = '[S]earch [W]ork [G]rep' } )

    end,
}
