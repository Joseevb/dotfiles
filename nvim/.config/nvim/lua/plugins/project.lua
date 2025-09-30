return {
	"ahmedkhalf/project.nvim",
	opts = {
		manual_mode = true,
		detection_methods = { "git" },
		patterns = { ".git" },
	},
	event = "VeryLazy",
	config = function(_, opts)
		require("project_nvim").setup(opts)
		-- Custom delete fn for history
		local history = require("project_nvim.utils.history")
		history.delete_project = function(project)
			for k, v in pairs(history.recent_projects) do
				if v == project.value then
					history.recent_projects[k] = nil
					return
				end
			end
		end
	end,
}
