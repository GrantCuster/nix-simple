local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node

ls.add_snippets("typescriptreact", {
	s("cl", {
		t('className="'),
	}),
})
