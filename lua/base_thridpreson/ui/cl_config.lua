UI = UI or {}

UI.themes = UI.themes or
{
	{
		name = "Dark",
		colors =
		{
			normalDark	= Color(220, 220, 220),
			deepGreen	= Color(33, 69, 50),
			deepDark	= Color(255, 255, 255),
			deepGold	= Color(237, 197, 0),
			easyLight	= Color(30, 30, 30),
			topLight	= Color(0, 0, 0),

			lightTrigg	= Color(33, 69, 50),

			colWhite	= Color(255, 255, 255),
			colAccept	= Color(10, 230, 10),
			colCancel	= Color(230, 10, 10),
			cameraPoint = Color(0, 255, 100)
		},
	},

	{
		name = "Light",
		colors =
		{
			normalDark	= Color(65, 65, 65),
			deepGreen	= Color(33, 69, 50),
			deepDark	= Color(30, 30, 30),

			easyLight	= Color(200, 200, 200),
			topLight	= Color(255, 255, 255),

			lightTrigg	= Color(8, 145, 178),

			colWhite	= Color(255, 255, 255),
			colAccept	= Color(10, 230, 10),
			colCancel	= Color(230, 10, 10),
			cameraPoint = Color(0, 255, 100)
		},
	},
}

local id = GetConVar("idl_uitheme"):GetInt()

UI.defaulttheme = 1
UI.theme = UI.themes[id] and id or UI.defaulttheme
UI.colors = UI.themes[UI.theme].colors