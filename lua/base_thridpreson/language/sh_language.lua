THRIDPRESON.Languages = THRIDPRESON.Languages or {}
THRIDPRESON.CurrentLanguage = THRIDPRESON.CurrentLanguage or "english"

local function load_language(filepath, lang_name)
    local f = file.Read(filepath, "LUA")
    if not f then return nil end
    local chunk, err = CompileString(f, filepath)
    if not chunk then
        ErrorNoHalt("Language file error (" .. lang_name .. "): " .. err .. "\n")
        return nil
    end
    local success, result = pcall(chunk)
    if not success or type(result) ~= "table" then
        ErrorNoHalt("Failed to execute language file: " .. lang_name .. "\n")
        return nil
    end
    return result
end

local function load_all_languages()
    local lang_path = THRIDPRESON.FolderName .. "/language/config/"
    local files, _ = file.Find(lang_path .. "sh_*.lua", "LUA")
    for _, filename in ipairs(files) do
        local name = string.match(filename, "^sh_(.+)%.lua$")
        if name then
            local full = lang_path .. filename
            local tbl = load_language(full, name)
            if tbl then
                THRIDPRESON.Languages[name] = tbl
            end
        end
    end
end

function THRIDPRESON.Translate(key, default)
    local lang = THRIDPRESON.Languages[THRIDPRESON.CurrentLanguage] or
                 THRIDPRESON.Languages["english"] or {}
    local node = lang
    for part in string.gmatch(key, "[^%.]+") do
        if type(node) ~= "table" then node = nil break end
        node = node[part]
    end
    if node and type(node) == "string" then return node end

    local eng = THRIDPRESON.Languages["english"]
    if eng then
        local ennode = eng
        for part in string.gmatch(key, "[^%.]+") do
            if type(ennode) ~= "table" then ennode = nil break end
            ennode = ennode[part]
        end
        if ennode and type(ennode) == "string" then return ennode end
    end
    return default or key
end

load_all_languages()