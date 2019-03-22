package = "co2"
version = "scm-0"

source = {
	url = "git://github.com/bartbes/co2",
}

description = {
	summary = "co2 is an extended replacement for the lua coroutine library",
	homepage = "https://github.com/bartbes/co2",
	license = "BSD",
}

dependencies = {
	"lua >= 5.1"
}

build = {
	type = "builtin",

	modules = {
		["co2"] = "src/co2.lua",
		["co2.core"] = "src/co2/core.lua",
	}
}
