THRIDPRESON = THRIDPRESON or {}

THRIDPRESON.FolderName    = "base_thridpreson"
THRIDPRESON.Author        = "CG Team"
THRIDPRESON.Email         = "n/a"

ENTITY	= FindMetaTable("Entity")
PLAYER	= FindMetaTable("Player")
NPC		= FindMetaTable("NPC")
VECTOR	= FindMetaTable("Vector")

include_sv 	= SERVER and include or function() end
include_cl 	= SERVER and AddCSLuaFile or include
include_sh 	= function(path) include_sv(path) include_cl(path) end

local function ginclude( f )
	if string.find(f, "sv_") then
		include_sv(f)
	elseif string.find(f, "cl_") then
		include_cl(f)
	else
		include_sh(f)
	end
end

local function include_dir( dir )
	local folder = THRIDPRESON.FolderName .. "/" .. dir .. "/"
	local files, folders = file.Find(folder .. "*", "LUA")
	local includelua = { config = {}, netvar = {}, init = {}, other = {} }
		
	for k, v in ipairs(files) do
		if v:sub(v:len() - 3, v:len()) != ".lua" then continue end

		if string.find(v, "config.") then
			table.insert(includelua.config, folder .. v)
		elseif string.find(v, "netvar.") then
			table.insert(includelua.netvar, folder .. v)
		elseif string.find(v, "init.") then
			table.insert(includelua.init, folder .. v)
		else
			table.insert(includelua.other, folder .. v)
		end
	end

	for k, v in pairs(includelua.config) do
		ginclude(v)
	end

	for k, v in pairs(includelua.netvar) do
		ginclude(v)
	end

	for k, v in pairs(includelua.init) do
		ginclude(v)
	end
	
	for k, v in pairs(includelua.other) do
		ginclude(v)
	end
	
	for k, v in ipairs(folders) do
		include_dir(dir .. "/" .. v)
	end
end

include_dir("modules", true)
include_dir("ui", false)