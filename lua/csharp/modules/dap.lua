local M = {}
local config_store = require("csharp.config")
local dap = require("dap")
local logger = require("csharp.log")

function M.get_debug_adapter()
  local config = config_store.get_config().dap

  logger.debug("[DBG DAP] config adapter ",{config=config,adapter=config.adapter_name})
  if config.adapter_name ~= nil then
    logger.debug("[DBG DAP] found a configured adapter. returning.",{adapter_name=config.adapter_name,adapter=dap.adapters[config.adapter_name]})
    return dap.adapters[config.adapter_name]
  end
  logger.debug("[DBG DAP ] building adapter")
  local debug_adapter = dap.adapters.coreclr

  if debug_adapter ~= nil then
    logger.debug("[DBG DAP ] returning default clr ? ",debug_adapter)
    return debug_adapter
  end

  logger.debug("[DBG DAP ] installing netcoredbg if needed")

  local mason = require("mason-registry")
  local package = mason.get_package("netcoredbg")

  if not package:is_installed() then
    package:install()
  end

  local path = package:get_install_path() .. "/netcoredbg"
  logger.debug("[DBG DAP] netcoredbg path",{path=path})

  dap.adapters.coreclr = {
    type = "executable",
    command = path,
    args = {
      "--interpreter=vscode",
    },
  }
  logger.debug("[DBg DAP] adpater is ",dap.adapters.coreclr)

  return dap.adapters.coreclr
end

return M
