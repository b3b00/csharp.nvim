local M = {}
local logger = require("csharp.log")

local function execute_command(cmd)
  logger.debug("[DBG CLI] command "..cmd)
  local file = io.popen(cmd .. " 2>&1")
  local output = file:read("*all")
  logger.debug("[DBG CLI] output",{output=output})
  local one, two, exit_code = file:close()  
  logger.debug("close return :: ",{one=one,two=two,code=exit_code})
  if (one) then
    logger.debug("successfully closed returning ",{output=output,exit_code=0})
    return output, 0
  else
    logger.debug("close failure returning ", {output=output,exit_code=exit_code})    
    return output, exit_code
  end
end

--- @param target string File path to solution or project
--- @param options string[]?
--- @return boolean
function M.build(target, options)
  local command = "dotnet build " .. target

  if options then
    command = command .. " " .. table.concat(options, " ")
  end

  logger.debug("Executing: " .. command, { feature = "dotnet-cli" })

  local output, exit_code = execute_command(command)
  logger.debug(output)
  --- @type boolean
  local build_succeded = true --exit_code == 0

  if build_succeded then
  else
    logger.debug("Build failed", { feature = "dotnet-cli" })
  end

  return build_succeded
end

--- @param options string[]?
function M.run(options)
  local command = "dotnet run"

  if options then
    command = command .. " " .. table.concat(options, " ")
  end

  logger.debug("Executing: " .. command, { feature = "dotnet-cli" })
  local current_window = vim.api.nvim_get_current_win()
  vim.cmd("split | term " .. command)
  vim.api.nvim_set_current_win(current_window)
end

return M
