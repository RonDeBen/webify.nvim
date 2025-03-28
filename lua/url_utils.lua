local M = {}
function M.split_remote_url(remote_url)
	-- Check if the URL uses SSH
	if remote_url:match("git@") then
		-- Replace `:` with `/` and convert SSH to HTTPS format
		remote_url = remote_url:gsub("git@", ""):gsub(":", "/")
	else
		-- Remove protocol for HTTPS URLs
		remote_url = remote_url:gsub("http[s]?://", "")
	end
	-- Match the components of the URL
	local pattern = "([%w%p]+)/([%w%p]+)/([%w%p]+)"
	local base, user, repo = string.match(remote_url, pattern)
	if not base then
		print("Pattern did not match")
		return nil
	end
	-- Remove `.git` from the repo name
	repo = repo:gsub("%.git$", "")
	return base, user, repo
end

local function url_encode(str)
	-- Encode reserved characters for URLs
	return str:gsub("([^%w%-._~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

function M.build_base_url_to_current_file(base, user, repo, branch, relative_path, line)
	local encoded_branch = url_encode(branch)
	local encoded_path = url_encode(relative_path)
	local url

	-- Check for different Git hosting platforms and format accordingly
	if string.find(base, "github") then
		url = string.format("https://%s/%s/%s/blob/%s/%s", base, user, repo, encoded_branch, encoded_path)
	elseif string.find(base, "gitlab") then
		url = string.format("https://%s/%s/%s/-/blob/%s/%s", base, user, repo, encoded_branch, encoded_path)
	elseif string.find(base, "adobe") then
		-- Adobe specific format without the '-/'
		url = string.format("https://%s/%s/%s/blob/%s/%s", base, user, repo, encoded_branch, encoded_path)
	else
		-- Default format for other Git hosting platforms
		url = string.format("https://%s/%s/%s/blob/%s/%s", base, user, repo, encoded_branch, encoded_path)
	end

	if line then
		return string.format("%s#L%d", url, line)
	end
	return url
end

return M
