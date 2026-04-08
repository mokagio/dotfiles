---@type vim.lsp.Config
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      shellcheckPath = 'shellcheck',
    },
  },
}
