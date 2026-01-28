return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'nvim-neotest/nvim-nio',
    },
    keys = {
        -- Basic debugging keymaps, feel free to change to your liking!
        {
            '<F6>',
            function()
                
                require('dap').continue()
            end,
            desc = 'Debug: Start/Continue',
        },
        {
            '<S-F6>',
            function()
                local dap = require('dap')
                local session = dap.session()
                local type = nil
                if session and session.config then
                   type = session.config.type
                end
                dap.terminate()
                if type == "python" then
                    vim.cmd("echo ' '")
                end
            end,
            desc = 'Debug: Terminate',
        },
        {
            '<S-F10>',
            function()
                require('dap').step_into()
            end,
            desc = 'Debug: Step Into',
        },
        {
            '<F10>',
            function()
                require('dap').step_over()
            end,
            desc = 'Debug: Step Over',
        },
        {
            '<F9>',
            function()
                require('dap').step_out()
            end,
            desc = 'Debug: Step Out',
        },
        {
            '<leader>db',
            function()
                require('dap').toggle_breakpoint()
            end,
            desc = 'Debug: Toggle Breakpoint',
        },
        {
            '<leader>dB',
            function()
                require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end,
            desc = 'Debug: Set Breakpoint',
        },
        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        {
            '<leader>dt', -- [d]ebug [t]oggle
            function()
                require('dapui').toggle()
            end,
            desc = 'Debug: See last session result.',
        },

        {
            '<leader>dh', -- [d]ebug to [h]ere
            function()
                require('dap').run_to_cursor()
            end,
            desc = 'Debug: Run to cursor'
        },

        {
            '<leader>dw', -- [d]ebug [w]atch
            function()
                require('dapui').elements.watches.add(vim.fn.expand("<cword>"))
            end,
            desc = 'Debug: Add to watch'
        },
    },
    config = function() 
        local dap = require 'dap'
        local dapui = require 'dapui'

        -- so it doesn't launch an external terminal
        require('dap').defaults.fallback.terminal_win_cmd = 'botright 10split new'

        dap.configurations.python = {
            {
                type = 'python';
                request = 'launch';
                name = "Launch file";
                program = "${file}";
                pythonPath = function()
                    return 'C:\\Python313\\python.exe'
                end;
                console = "integratedTerminal",
            },    

        --     {
        --         type = 'python',
        --         request = 'launch',
        --         name = 'Debug Game',
        --         program = 'main.py',  
        --         pythonPath = function() return 'C:\\Python313\\python.exe' end,
        --         cwd = 'W:/newgame/src/newgame',
        --         env = function()
        --             if not vim.fn.getenv("DEBUGPY_ENABLE") then
        --                 vim.fn.setenv("DEBUGPY_ENABLE", "1")
        --             end
        --         end,
        --         stopOnEntry = true,
        --         justMyCode = true,
        --         subProcess = true,
        --         console = "integratedTerminal",
        --     },
        }

        dap.adapters.python = {
            type = 'executable',
            command = 'C:\\Python313\\python.exe',
            args = { '-m', 'debugpy.adapter' };
        }

        dapui.setup {
            icons = { expanded = '', collapsed = '', current_frame = '*' },
            layouts = { 
                {
                    elements = 
                    { 
                        {
                            id = "console",
                            size = 0.33 
                        }, 
                        {
                            id = "watches",
                            size = 0.67 
                        }, 
                    },
                    position = "left",
                    size = 80
                },
            },
            controls = {
                element = "console",
                enabled = true,
                icons = {
                    pause = '',
                    play = '',
                    step_into = '',
                    step_over = '',
                    step_out = '',
                    -- step_back = 'b',
                    run_last = '',
                    terminate = '',
                    -- disconnect = '⏏',
                },
            },
            render = 
            {
                indent = 1,
                max_value_lines = 100
            },
        }

        dap.listeners.before.event_initialized['dapui_config'] = function()
            local ok, neotree = pcall(require, 'neo-tree.command')
            if ok then
                neotree.execute({ source = 'filesystem', action = 'close' })
            end
        end

        dap.listeners.after.event_initialized['dapui_config'] = dapui.open

        -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        -- dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end
}

    


