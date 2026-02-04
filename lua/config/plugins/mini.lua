return {
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Enable Mini Git (provides branch/diff info)
      require('mini.git').setup()

      -- Statusline
      local statusline = require('mini.statusline')
      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git           = MiniStatusline.section_git({ trunc_width = 75 })          -- <- mini.git info
            local filename      = '%F'
            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location      = MiniStatusline.section_location({ trunc_width = 75 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
              '%<', -- Mark truncation point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { location } },
            })
          end,
        },
        -- Optional: turn off icons if you don't use a Nerd Font
        -- use_icons = false,
      })

      -- Other mini modules you already use
      require('mini.bufremove').setup({})
      require('mini.ai').setup({ n_lines = 500 })
      require('mini.surround').setup({})
    end,
  },
}
