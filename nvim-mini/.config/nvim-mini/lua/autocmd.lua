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
