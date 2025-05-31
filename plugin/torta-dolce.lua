vim.api.nvim_create_user_command("TortaDolce", function(opts)
	package.loaded["torta-dolce"] = nil

	require("torta-dolce").youtrack_issues()
end, {})
