local HDsearch="https://harddrop.com/wiki?search="
return{
	--Example:
	{"DT cannon",--Name
		"dt",--Search-keywords, separate with space
		"term",--Item type, help/other/game/term/english/name
		"Double-Triple Cannon\nsearch HD wiki for more",--text, allow \t and \n
		HDsearch.."dt",--URL, if need
	},
}