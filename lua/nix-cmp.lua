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

-- turn a set of strings in to a set compatible with nvim-cmp
-- { "foo", "bar", "yo", "lo" }
-- ==>
-- { { label = "foo"} , ..., { label = "lo" } }
local function makeLabels(set)
    local t = {}
    for _, v in pairs(set) do
        local entry = {}
        entry.label = v
        table.insert(t, entry)
    end
    return t
end

-- Get the keys of a nix attribute set into a lua set of strings
local function attrNames(set)
    local cmd = string.format("nix-instantiate --eval -E 'builtins.attrNames %s'", set)
    local output = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        print("nix-cmp: nix-instantiate failed for " .. set)
        return {}
    end

    -- Trim leading/trailing spaces and brackets
    output = output:gsub("^%s*%[(.+)%]%s*$", "%1")

    local t = {}
    for name in output:gmatch("\"([^\"]+)\"") do
        table.insert(t, name)
    end
    return t
end

-- Get the name of all builtins of nix into list
local function get_builtins()
    local names = attrNames("builtins")
    return makeLabels(names)
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
