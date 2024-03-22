local function stringHasSpace(s)
    return string.find(s, " ") ~= nil
end

-- extract the last word of a string
local function last(str)
    if not stringHasSpace(str) then
        return str
    end
    local lastWord = str:match(".*%s(%S+)$")
    return lastWord or ""
end

-- turn a string with a list like
-- [ "foo" "bar" "yo" "lo" ]
-- into a table of tables like
-- { { label = "foo"} , ..., { label = "lo" } }
-- This format is expected by nvim-cmp
local function makeLabels(str)
    local t = {}
    for item in str:gmatch("\"([^\"]+)\"") do
        local entry = {}
        entry.label = item
        table.insert(t, entry)
    end
    return t
end

-- Get the name of all builtins of nix into list
local function get_builtins()
    local output = vim.fn.system("nix-instantiate --eval -E 'builtins.attrNames builtins'")

    if vim.v.shell_error ~= 0 then
        print("nix-cmp: nix-instantiate failed")
        return {}
    end

    -- Trim leading/trailing spaces and brackets
    output = output:gsub("^%s*%[(.+)%]%s*$", "%1")

    local table_names = makeLabels(output)
    return table_names
end

BuiltinsTable = get_builtins()


-- The remainder of this file is file declares a source for nvim-cmp
-- (see https://github.com/hrsh7th/nvim-cmp)

local source = {}

function source:is_available()
  return true
end

function source:get_debug_name()
  return 'nix-cmp'
end

function source:get_trigger_characters()
  return { '.' }
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  local compl_ctxt = params.completion_context
  if compl_ctxt.triggerCharacter then
      local last_word = last(params.context.cursor_line)
      print("builtins= " .. vim.inspect(BuiltinsTable))
      if last_word == "builtins." then
          callback(BuiltinsTable)
      end
  end
end

function source:resolve(completion_item, callback)
  callback(completion_item)
end

function source:execute(completion_item, callback)
  callback(completion_item)
end

return source
