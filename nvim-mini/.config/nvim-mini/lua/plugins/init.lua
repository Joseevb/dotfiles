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
			end
		end
	end

	return plugins
end

local function run_build_command(plugin, plugin_path)
	if not plugin.build then
		return
	end

	local build_cmd = plugin.build
	if type(build_cmd) == "function" then
		local ok, result = pcall(build_cmd)
		if not ok then
			print("Error running build function for " .. (plugin.setup_name or "unknown") .. ": " .. tostring(result))
		end
		return
	end

	-- Handle string build commands
	if type(build_cmd) == "string" then
		-- Change to plugin directory for build
		local original_cwd = vim.fn.getcwd()
		vim.fn.chdir(plugin_path)

		local handle = io.popen(build_cmd .. " 2>&1")
		if handle then
			local output = handle:read("*a")
			local success = handle:close()

			-- Restore original directory
			vim.fn.chdir(original_cwd)

			if not success then
				print("Build failed for " .. (plugin.setup_name or "plugin") .. ":\n" .. output)
			end
		else
			vim.fn.chdir(original_cwd)
			print("Failed to execute build command for " .. (plugin.setup_name or "plugin"))
		end
	end
end

local function get_plugin_path(plugin_src)
	-- Extract plugin name from src URL
	local plugin_name = plugin_src:match("([^/]+)%.git$") or plugin_src:match("([^/]+)$")
	if plugin_name:match("%.nvim$") then
		plugin_name = plugin_name:match("(.+)%.nvim$")
	end

	-- Construct the path where vim.pack would install the plugin
	local pack_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. plugin_name .. ".nvim"
	return pack_path
end

function M.setup()
	-- First pass: install all plugins
	local loaded_plugins = load_plugin_configs()

	local plugins = {}
	local plugin_names = {}
	local deferred_plugins = {}
	local deferred_plugin_names = {}

	for _, plugin in ipairs(loaded_plugins) do
		if plugin.defer == true then
			table.insert(deferred_plugins, plugin)
			table.insert(deferred_plugin_names, plugin)
		else
			table.insert(plugins, plugin)
			table.insert(plugin_names, plugin)
		end
	end

	vim.pack.add(plugin_names)

	-- Run build commands for plugins that need them
	vim.schedule(function()
		for _, plugin in ipairs(plugins) do
			if plugin.build then
				local plugin_path = get_plugin_path(plugin.src)
				if vim.fn.isdirectory(plugin_path) == 1 then
					run_build_command(plugin, plugin_path)
				end
			end
		end
	end)

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

						if plugin.post_config then
							local success, result = pcall(plugin.post_config)
							if not success then
								print("Error running post_config for " .. plugin.setup_name .. ": " .. tostring(result))
							end
						end
					else
						print("Failed to require " .. plugin.setup_name)
					end
				end
				if plugin.defer then
					table.insert(deferred_plugins, plugin)
				end
			end
		end
	end)

	-- Third pass: load deferred plugins
	vim.defer_fn(function()
		vim.pack.add(deferred_plugin_names)

		-- Run build commands for deferred plugins
		for _, plugin in ipairs(deferred_plugins) do
			if plugin.build then
				local plugin_path = get_plugin_path(plugin.src)
				if vim.fn.isdirectory(plugin_path) == 1 then
					run_build_command(plugin, plugin_path)
				end
			end
		end

		-- Configure deferred plugins
		for _, plugin in ipairs(deferred_plugins) do
			if plugin.setup_name then
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
									"Error calling opts function for " .. plugin.setup_name .. ": " .. tostring(result)
								)
								opts = {}
							end
						end

						vim.defer_fn(function()
							module.setup(opts)
						end, 100)
					elseif type(module.setup) == "function" then
						module.setup({})
					end
				else
					print("Failed to require " .. plugin.setup_name)
				end
			end
		end
	end, 100)
end

return M
