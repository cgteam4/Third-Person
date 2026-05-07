CreateClientConVar("thridpreson_language", "english", true, false)

cvars.AddChangeCallback("thridpreson_language", function(_, _, new)
    THRIDPRESON.CurrentLanguage = new
    if UI and UI.CameraMenu and UI.CameraMenu:IsValid() then
        UI.CameraMenu:Remove()
        CreateCameraSettings()
    end
end)

THRIDPRESON.CurrentLanguage = GetConVar("thridpreson_language"):GetString() or "english"