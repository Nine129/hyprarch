if os.getenv("YAZI_NO_SESSION") ~= "1" then
    require("autosession"):setup()
end
require("full-border"):setup()
require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})
