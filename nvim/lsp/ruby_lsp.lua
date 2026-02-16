---@type vim.lsp.Config
return {
  cmd = { 'ruby-lsp' },
  filetypes = { 'ruby', 'eruby' },
  root_markers = { 'Gemfile', '.git' },
  init_options = {
    formatter = 'auto',
  },
}
