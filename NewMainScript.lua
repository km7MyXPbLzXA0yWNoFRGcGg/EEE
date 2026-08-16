-- NewMainScript.lua (patched to load antilag)
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/km7MyXPbLzXA0yWNoFRGcGg/EEE/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/km7MyXPbLzXA0yWNoFRGcGg/EEE')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

-- Attempt to download and load the antilag module (non-fatal)
do
	local ok, err = pcall(function()
		-- Ensure the file is present (downloadFile writes it)
		downloadFile('newvape/libraries/antilag.lua')
		if isfile('newvape/libraries/antilag.lua') then
			-- Load the module safely
			local suc, mod = pcall(function()
				return loadstring(readfile('newvape/libraries/antilag.lua'), 'antilag')()
			end)
			if suc and type(mod) == 'table' then
				-- Expose the module globally for other scripts if desired
				shared.R12SAStandaloneAntilag = mod
				shared.AntiLag = mod
				-- If module has a status printer, run it periodically for monitoring
				if type(mod.PrintStatus) == 'function' then
					spawn(function()
						while true do
							task.wait(15)
							pcall(mod.PrintStatus)
						end
					end)
				end
			else
				warn('[NewMainScript] antilag loaded but did not return a module table or errored:', mod)
			end
		end
	end)
	if not ok then
		warn('[NewMainScript] Failed to download/load antilag:', err)
	end
end

return loadstring(downloadFile('newvape/main.lua'), 'main')()
