# lua-promise

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-promise"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-promise",
	"module": {
		"dir": "dmc_lua",
		"files": [
			"lua_promise.lua"
		],
		"requires": [
			"lua-objects"
		]
	},
	"tests": {
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "lua-promise", module_config )


