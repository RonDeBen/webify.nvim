local M = {}

local function split_string(string)
    lines = {}
    for s in string:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    return lines
end

function M.get_remotes()
    local output = vim.fn.system { 'git', 'remote' }
    local error = vim.v.shell_error
    if error ~= 0 then
        print(output)
        return nil
    end
    return split_string(output)
end

function M.get_repo_root()
    local output = vim.fn.system { 'git', 'rev-parse', '--show-toplevel' }
    local error = vim.v.shell_error
    if error ~= 0 then
        print(output)
        return nil
    end
    return output:gsub('%s+', '')
end

function M.get_current_branch()
    local output = vim.fn.system { 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }
    local error = vim.v.shell_error
    if error ~= 0 then
        print(output)
        return nil
    end
    return output:gsub('%s+', '')
end

function M.get_remote_url(remote)
    local output = vim.fn.system { 'git', 'remote', 'get-url', remote }
    local error = vim.v.shell_error
    if error ~= 0 then
        print(output)
        return nil
    end
    return output:gsub('%s+', '')
end

function M.get_default_branch()
    local output = vim.fn.system { 'git', 'remote', 'show', 'origin' }
    local branch = output:match('HEAD branch:%s+(%S+)')
    return branch or "main" -- Fallback to "main"
end

return M
