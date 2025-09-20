UI.CameraPosition = UI.CameraPosition or {x = 0.4, y = 0.4}

function CreateCameraSettings()

    if IsValid(UI.CameraMenu) then 
        UI.CameraMenu:Remove()
    end

    UI.CameraMenu = vgui.Create("DFrame")
    local frame = UI.CameraMenu
    frame:SetSize( 400, 480 )
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetDrawOnTop(true)
    frame:MakePopup()
    frame:Center()
    
    local screenWidth = ScrW()
    local screenHeight = ScrH()
    local frameWidth = frame:GetWide()
    local frameHeight = frame:GetTall()

    frame:SetPos(screenWidth - frameWidth - 10, 10)

    function frame:Paint(w, h)
        surface.SetDrawColor(0, 0, 0 , 0)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0 , 0)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    frame.OnClose = function()
        if IsValid(g_ContextMenu) and g_ContextMenu:IsVisible() then
            g_ContextMenu:Close()
        end
    end
    
    local mainContainer = vgui.Create("DPanel", frame)
    mainContainer:Dock(FILL)
    mainContainer:DockMargin(5, 5, 5, 5)
    mainContainer:SetPaintBackground(false)

    local viewPanel = vgui.Create("DPanel", mainContainer)
    frame.ViewPanel = viewPanel
    viewPanel:Dock(TOP)
    viewPanel:SetTall(300)
    viewPanel:DockMargin(0, 0, 0, 5)

    viewPanel.Paint = function(self, w, h)
        surface.SetDrawColor(UI.colors.easyLight.r, UI.colors.easyLight.g, UI.colors.easyLight.b, 220)
        surface.DrawRect(0, 0, w, h)
    end
    
    viewPanel.PlayerPos = {
        x = UI.CameraPosition.x * viewPanel:GetWide(),
        y = UI.CameraPosition.y * viewPanel:GetTall()
    }
    
    viewPanel.Dragging = false
    viewPanel.Hovered = false

    function viewPanel:PaintOver(w, h)
        surface.SetDrawColor(UI.colors.normalDark)
        surface.DrawLine(w/2, 0, w/2, h)
        surface.DrawLine(0, h/2, w, h/2)

        surface.SetDrawColor(UI.colors.deepGold)
        surface.DrawCircle(w/2, h/2, 10)

        surface.SetDrawColor(UI.colors.cameraPoint)
        surface.DrawCircle(self.PlayerPos.x, self.PlayerPos.y, 6)

        surface.SetDrawColor(UI.colors.lightTrigg)
        surface.DrawLine(w/2, h/2, self.PlayerPos.x, self.PlayerPos.y)

        draw.SimpleText("Вперед", "DermaDefault", w/2 + 10, 10, UI.colors.normalDark)
        draw.SimpleText("Назад", "DermaDefault", w/2 + 10, h - 20, UI.colors.normalDark)
        draw.SimpleText("Влево", "DermaDefault", 10, h/2 - 20, UI.colors.normalDark)
        draw.SimpleText("Вправо", "DermaDefault", w - 40, h/2 - 20, UI.colors.normalDark)
    end

    function viewPanel:OnSizeChanged(w, h)
        self.PlayerPos.x = UI.CameraPosition.x * w
        self.PlayerPos.y = UI.CameraPosition.y * h
    end

    function viewPanel:OnCursorMoved(x, y)
        if self.Dragging then
            self.PlayerPos.x = math.Clamp(x, 0, self:GetWide())
            self.PlayerPos.y = math.Clamp(y, 0, self:GetTall())
            UpdateCameraPosition(self.PlayerPos, self:GetWide(), self:GetTall())
        end
    end

    function viewPanel:OnMousePressed()
        self.Dragging = true
        self:MouseCapture(true)
    end

    function viewPanel:OnMouseReleased()
        self.Dragging = false
        self:MouseCapture(false)
    end

    local controlPanel = vgui.Create("DPanel", mainContainer)
    controlPanel:Dock(FILL)
    controlPanel:DockMargin(0, 0, 0, 0)
    
    controlPanel.Paint = function(self, w, h)
        surface.SetDrawColor(UI.colors.easyLight.r, UI.colors.easyLight.g, UI.colors.easyLight.b, 220)
        surface.DrawRect(0, 0, w, h)
    end

    local function UpdatePoint()
        if not IsValid(viewPanel) then return end
        
        local w = viewPanel:GetWide()
        local h = viewPanel:GetTall()
        
        if w > 0 and h > 0 then
            viewPanel.PlayerPos = {
                x = GetConVar("idl_thirdperson_y"):GetFloat() * w,
                y = GetConVar("idl_thirdperson_x"):GetFloat() * h
            }
        end
    end

    local function CreateSlider(parent, sliderLabel, convar, min, max)
        local sliderPanel = vgui.Create("DPanel", parent)
        sliderPanel:Dock(TOP)
        sliderPanel:SetTall(30)
        sliderPanel:DockMargin(0, 5, 0, 0)
        sliderPanel:SetPaintBackground(false)
        
        local lbl = vgui.Create("DLabel", sliderPanel)
        lbl:SetText(sliderLabel)
        lbl:SetTextColor(UI.colors.normalDark)
        lbl:SetWide(180)
        lbl:Dock(LEFT)
        
        local slider = vgui.Create("DNumSlider", sliderPanel)
        slider:Dock(FILL)
        slider:SetMin(min)
        slider:SetMax(max)
        slider:SetDecimals(2)
        slider:SetConVar(convar)
        slider:SetText("")
        
        function slider:PerformLayout()
            self.Slider:SetHeight(20)
            self.Scratch:SetTextColor(UI.colors.normalDark)
        end
        
        slider.OnValueChanged = function(_, value)
            if convar == "idl_thirdperson_x" then
                UI.CameraPosition.y = value
            elseif convar == "idl_thirdperson_y" then
                UI.CameraPosition.x = value
            end
            
            UpdatePoint()
        end
        
        return slider
    end

    CreateSlider(controlPanel, "Смещение камеры по карденате Y", "idl_thirdperson_x", 0, 1)
    CreateSlider(controlPanel, "Смещение камеры по карденате X", "idl_thirdperson_y", 0, 1)
    CreateSlider(controlPanel, "Смещение камеры по карденате Z", "idl_thirdperson_z", 0, 1)

    local resetBtn = vgui.Create("DButton", controlPanel)
    resetBtn:Dock(BOTTOM)
    resetBtn:SetText("Сбросить настройки")
    resetBtn:DockMargin(0, 10, 0, 0)
    resetBtn.DoClick = function()
        RunConsoleCommand("idl_thirdperson_x", "0.4")
        RunConsoleCommand("idl_thirdperson_y", "0.4")
        RunConsoleCommand("idl_thirdperson_z", "0.3")
        
        UI.CameraPosition = {x = 0.4, y = 0.4}
        if IsValid(viewPanel) then
            UpdatePoint()
        end
    end
    
    function frame:OnClose()
        if IsValid(self.ViewPanel) then
            local w = self.ViewPanel:GetWide()
            local h = self.ViewPanel:GetTall()
            
            if w > 0 and h > 0 then
                UI.CameraPosition = {
                    x = self.ViewPanel.PlayerPos.x / w,
                    y = self.ViewPanel.PlayerPos.y / h
                }
            end
        end
    end
    
    UpdatePoint()
end

function UpdateCameraPosition(pos, w, h)
    UI.CameraPosition = {
        x = pos.x / w,
        y = pos.y / h
    }
    
    RunConsoleCommand("idl_thirdperson_x", tostring(UI.CameraPosition.y))
    RunConsoleCommand("idl_thirdperson_y", tostring(UI.CameraPosition.x))
end

hook.Add("OnContextMenuOpen", "CameraMenuOpen", function()
    if not IsValid(UI.CameraMenu) then
        CreateCameraSettings()
    end
end)

hook.Add("OnContextMenuClose", "CameraMenuClose", function()
    if IsValid(UI.CameraMenu) then
        UI.CameraMenu:Remove()
    end
end)