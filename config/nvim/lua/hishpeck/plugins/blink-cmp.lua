-- Vue's language server offers every attribute inside a start tag; after `@` only
-- events are relevant and after `:` only bindings (minus the `:on-*` duplicates)
local function is_in_vue_start_tag()
	local node = vim.treesitter.get_node()
	if not node then
		return false
	end

	local target_nodes = { "start_tag", "self_closing_tag", "directive_attribute" }

	local is_tag = vim.tbl_contains(target_nodes, node:type())
	if not is_tag and node:parent() then
		is_tag = vim.tbl_contains(target_nodes, node:parent():type())
	end

	return is_tag
end

local function filter_vue_directives(ctx, items)
	if vim.bo[ctx.bufnr].filetype ~= "vue" or not is_in_vue_start_tag() then
		return items
	end

	local last_char = ctx.line:sub(ctx.cursor[2], ctx.cursor[2])

	if last_char == "@" then
		return vim.tbl_filter(function(item)
			return item.label:match("^@") ~= nil
		end, items)
	elseif last_char == ":" then
		return vim.tbl_filter(function(item)
			return item.label:match("^:") ~= nil and item.label:match("^:on%-") == nil
		end, items)
	end

	return items
end

return {
	"saghen/blink.cmp",
	version = "1.*", -- release tags ship prebuilt fuzzy matcher binaries
	event = "InsertEnter",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"fang2hou/blink-copilot",
	},
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-e>"] = { "cancel", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-l>"] = { "snippet_forward", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },
		},
		completion = {
			list = {
				selection = { preselect = false, auto_insert = true },
			},
			menu = {
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
				},
			},
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			ghost_text = { enabled = true, show_without_selection = true },
		},
		sources = {
			default = { "copilot", "lsp", "snippets", "buffer", "path" },
			per_filetype = {
				php = { inherit_defaults = true, "blade-nav" },
				blade = { inherit_defaults = true, "blade-nav" },
			},
			providers = {
				lsp = {
					transform_items = filter_vue_directives,
				},
				snippets = {
					opts = {
						extended_filetypes = { php = { "blade" } },
					},
				},
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					async = true,
				},
				["blade-nav"] = {
					name = "blade-nav",
					module = "blade-nav.integrations.blink",
				},
			},
		},
		cmdline = { enabled = false },
	},
}
