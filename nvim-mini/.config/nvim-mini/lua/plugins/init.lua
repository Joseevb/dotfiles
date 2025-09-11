local M = {}

local function load_plugin_configs()
	local plugins = {}
	local config_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
	local plugins_path = config_path

	local stat = vim.loop.fs_stat(plugins_path)
	if not stat or stat.type ~= "directory" then
		print("Plugins directory doesn't exist or isn't a directory")
		return plugins
	end

	for name, file_type in vim.fs.dir(plugins_path) do
		if file_type == "file" and name:match("%.lua$") and name ~= "init.lua" then
			local filename = name:match("(.+)%.lua$")

			local ok, plugin_config = pcall(require, "plugins." .. filename)

			if ok and type(plugin_config) == "table" then
				if plugin_config[1] ~= nil then
					vim.list_extend(plugins, plugin_config)
				else
					table.insert(plugins, plugin_config)
				end
			elseif not ok then
				print("Error requiring " .. filename .. ": " .. tostring(plugin_config))
			end
		end
	end

	return plugins
end

function M.setup()
	-- First pass: install all plugins
	local plugins = load_plugin_configs()
	for _, plugin in ipairs(plugins) do
		vim.pack.add({ plugin.src })
	end

	-- Second pass: configure plugins
	vim.schedule(function()
		for _, plugin in ipairs(plugins) do
			if plugin.setup_name then
				if plugin.lazy then
					vim.defer_fn(function()
						local ok, module = pcall(require, plugin.setup_name)
						if ok then
							local opts = nil

							if plugin.opts then
								if type(plugin.opts) == "function" then
									local success, result = pcall(plugin.opts)
									if success then
										opts = result
									else
										print(
											"Error calling opts function for "
												.. plugin.setup_name
												.. ": "
												.. tostring(result)
										)
										opts = {}
									end
								else
									opts = plugin.opts
								end
							end

							if opts then
								module.setup(opts)
							elseif type(module.setup) == "function" then
								module.setup({})
							end
						else
							print("Failed to require lazy plugin " .. plugin.setup_name)
						end
					end, 100)
				else
					local ok, module = pcall(require, plugin.setup_name)
					if ok then
						if plugin.opts then
							local opts = plugin.opts

							if type(opts) == "function" then
								local success, result = pcall(opts)
								if success then
									opts = result
								else
									print(
										"Error calling opts function for "
											.. plugin.setup_name
											.. ": "
											.. tostring(result)
									)
									opts = {}
								end
							end

							module.setup(opts)
						elseif type(module.setup) == "function" then
							module.setup({})
						end
					else
						print("Failed to require " .. plugin.setup_name)
					end
				end
			end
		end
	end)
end

return M
