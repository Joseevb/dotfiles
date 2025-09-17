vim.api.nvim_set_hl(0, "YankHighlight", {
	background = "#6c7086",
	bold = true,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			timeout = 200,
			higroup = "YankHighlight",
		})
	end,
})

function _G.pack_update_command(args)
	if next(args.fargs) ~= nil then
		local plugin_names = args.fargs
		vim.notify("Updating specific packs: " .. table.concat(plugin_names, ",") .. "...", vim.log.levels.INFO)
		vim.pack.update(plugin_names)
	else
		vim.notify("Updating all packs...", vim.log.levels.INFO)
		vim.pack.update()
	end

	vim.notify("Pack update process initiated!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("PackUpdate", _G.pack_update_command, {
	nargs = "*",
	desc = "Update installed packs (plugins/dependencies)",
	complete = "customlist,v:lua.get_available_packs",
})

function _G.get_available_packs(ArgLead)
	local all_packs_data = vim.pack.get()
	local all_pack_names = {}
	for _, pack_info in ipairs(all_packs_data) do
		if pack_info.spec and pack_info.spec.name then
			table.insert(all_pack_names, pack_info.spec.name)
		end
	end

	local suggestions = {}
	for _, pack_name in ipairs(all_pack_names) do
		if pack_name:sub(1, #ArgLead) == ArgLead then
			table.insert(suggestions, pack_name)
		end
	end
	return suggestions
end

local function project_picker(project_name)
	local project = require("project_nvim")
	local fzf = require("fzf-lua")

	-- Get the project history
	local projects = project.get_recent_projects()

	if not projects or #projects == 0 then
		print("No recent projects found")
		return
	end

	-- If project_name is provided, try to find and jump directly
	if project_name and project_name ~= "" then
		local found_project = nil
		local project_name_lower = project_name:lower()

		for _, proj_path in ipairs(projects) do
			local name = vim.fn.fnamemodify(proj_path, ":t"):lower()
			if name:find(project_name_lower, 1, true) then
				found_project = proj_path
				break
			end
		end

		if found_project then
			vim.cmd("cd " .. vim.fn.fnameescape(found_project))
			print("Changed to: " .. found_project)
			return -- Exit early, don't show the picker
		else
			print("Project '" .. project_name .. "' not found in recent projects")
			return -- Exit early on error
		end
	end

	-- Format projects for display (show basename and full path)
	local formatted_projects = {}
	for _, proj_path in ipairs(projects) do
		local name = vim.fn.fnamemodify(proj_path, ":t") -- basename
		table.insert(formatted_projects, string.format("%-30s %s", name, proj_path))
	end

	fzf.fzf_exec(formatted_projects, {
		prompt = "Projects❯ ",
		preview_window = "right:50%",
		actions = {
			["default"] = function(selected)
				if selected and #selected > 0 then
					-- Extract the full path from the formatted string
					local full_path = selected[1]:match("%S+%s+(.+)")
					if full_path and vim.fn.isdirectory(full_path) == 1 then
						vim.cmd("cd " .. vim.fn.fnameescape(full_path))
						print("Changed to: " .. full_path)
					else
						print("Directory not found: " .. (full_path or "unknown"))
					end
				end
			end,
			["ctrl-t"] = function(selected)
				-- Open in new tab
				if selected and #selected > 0 then
					local full_path = selected[1]:match("%S+%s+(.+)")
					if full_path and vim.fn.isdirectory(full_path) == 1 then
						vim.cmd("tabnew")
						vim.cmd("cd " .. vim.fn.fnameescape(full_path))
						print("Opened in new tab: " .. full_path)
					end
				end
			end,
			["ctrl-s"] = function(selected)
				-- Split and open
				if selected and #selected > 0 then
					local full_path = selected[1]:match("%S+%s+(.+)")
					if full_path and vim.fn.isdirectory(full_path) == 1 then
						vim.cmd("split")
						vim.cmd("cd " .. vim.fn.fnameescape(full_path))
						print("Split and changed to: " .. full_path)
					end
				end
			end,
		},
		preview = function(selected)
			if selected and #selected > 0 then
				local full_path = selected[1]:match("%S+%s+(.+)")
				if full_path and vim.fn.isdirectory(full_path) == 1 then
					-- Show directory contents as preview
					local files = vim.fn.systemlist("ls -la " .. vim.fn.shellescape(full_path))
					return table.concat(files, "\n")
				end
			end
			return "No preview available"
		end,
	})
end

-- Create a user command
vim.api.nvim_create_user_command("FzfProjects", function(opts)
	project_picker(opts.args)
end, {
	nargs = "?", -- Optional argument
	desc = "Find Projects (optionally filter by name)",
})
