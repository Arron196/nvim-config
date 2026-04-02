return {
  init_options = {
    settings = {
      lineLength = 88,
      organizeImports = true,
    },
  },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
