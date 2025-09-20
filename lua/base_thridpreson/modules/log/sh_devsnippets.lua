local function GetLoggingName( chan )
	chan = string.lower( chan )
	if chan == "log" or chan == "logs" or chan == "logging" then
		return "LOG"
	elseif chan == "db" or chan == "database" then
		return "DB"
	elseif chan == "gm" or chan == "gamemode" then
		return "GM"
	elseif chan == "deb" or chan == "debug" then
		return "DEBUG"
	elseif chan == "mis" or chan == "miss" then
		return "MISSING"
	elseif chan == "err" or chan == "error" then
		return "ERROR"
	else
		return string.upper( chan)
	end
end

function cg_loggin_print( chan, args )
	if !isstring( chan ) then return end
	if !isstring( args ) then return end

	local cn = GetLoggingName( chan )
	cg_nl()
	MsgC("[" .. cn .. "] ", args)
	cg_nl()
end

function cg_nl()
	MsgC('\n')
end