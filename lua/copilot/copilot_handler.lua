local user_data = require('copilot.setup').get_cred()
local util = require('copilot.util')
local M = {}

local send_editor_info = function (a, b, c, d)
   local responses = vim.lsp.buf_request_sync(0, 'setEditorInfo', {
      editorPluginInfo = {
         name = 'copilot.vim',
         version = '1.1.0',
      },
      editorInfo= {
         version = '0.6.1',
         name = "Neovim",
      },
   }, 600)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.getCompletions = true

M.start = function (config)
   vim.lsp.start_client({
      cmd = {require('copilot.util').get_copilot_path(config)},
      cmd_env = {
         ["GITHUB_USER"] = user_data.user,
         ["GITHUB_TOKEN"] = user_data.token,
         ["COPILOT_AGENT_VERBOSE"] = 1,
      },
      filetypes = { "rust" },
      handlers={
         ["getCompletions"] = function () print("get completions") end,
         ["textDocumentSync"] = function () print("handle") end,
      },
      name = "copilot",
      trace = "messages",
      root_dir = vim.loop.cwd(),
      autostart = true,
      on_init = function(client, _)
         vim.lsp.buf_attach_client(0, client.id)
	 vim.api.nvim_command([[autocmd BufEnter * lua require('copilot.copilot_handler')._on_init(]] + client.id + ")")
         --[[ vim.api.nvim_create_autocmd({'BufEnter'}, {
            callback = function ()
            end,
            once = false,
         }) ]]
      end,
      on_attach = function()
         send_editor_info()
      end
   })
end

M._on_init = function(client_id)
    if not vim.lsp.buf_get_clients(0)[client_id] then
	vim.lsp.buf_attach_client(0, client_id)
    end
end

return M
