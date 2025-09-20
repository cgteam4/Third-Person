CreateClientConVar("idl_uitheme", 1, true, false)
CreateClientConVar("idl_thirdperson", 0, true, false)
CreateClientConVar("idl_thirdperson_x", 0.4, true, false, "", 0, 1 )
CreateClientConVar("idl_thirdperson_y", 0.4, true, false, "", 0, 1 )
CreateClientConVar("idl_thirdperson_z", 0.3, true, false, "", 0, 1 )

//Основные переменные камеры.
local convar_on_off = GetConVar("idl_thirdperson")
local convar_x      = GetConVar("idl_thirdperson_x")
local convar_y      = GetConVar("idl_thirdperson_y")
local convar_z      = GetConVar("idl_thirdperson_z")

//Состояние включения и интерполяция.
local enable = convar_on_off:GetBool()
local x      = Lerp( convar_x:GetFloat(), -40, -120 )
local y      = Lerp( convar_y:GetFloat(), -40, 40   )
local z      = Lerp( convar_z:GetFloat(), -15, 15   )

//Основные переменные расположения камеры.
local hold_angle = Angle()
local view_angle = Angle()
local view_pos   = Vector()

//Переменная для предотвращение клиппинга.
local trmask = Vector(4, 4, 4)

//Переменная для фиксации камеры.
local key = input.GetKeyCode( "v" )

local keyf2 = true

//Основная функция 3-ого лица
local function IDL_UI_ThridPresonCalcView(ply, pos, angles, fov)

    //Проверка на состояние камеры.
    if not enable then 
        return 
    end

    //Проверка когда камера не должна работать.  
    if ply:InVehicle() or ply:GetObserverMode() != OBS_MODE_NONE or not ply:Alive() then 
        return 
    end

    //Проверка для фиксации камеры при повороте, с зажатой кнопкой.
    if input.IsKeyDown( key ) then
        if not hold_angle then
            hold_angle = angles
        end
    else
        hold_angle = nil
    end

    //Переменные для расчёта камеры относительно игрока.
    view_angle  = hold_angle or angles
    view_pos    = pos + view_angle:Forward() * x + view_angle:Right() * y + view_angle:Up() * z

    //Переменная (таблица) для предотвращения прохождения камеры сквозь стены.
    local tr = util.TraceHull ({
        start           = pos,
        endpos          = view_pos,
        mask            = MASK_SHOT_HULL,
        collisiongroup  = COLLISION_GROUP_WORLD,
        mins            = -trmask,
        maxs            = trmask
    })

    //Проверка для перемещения камеры, в точку столкновения со стеной.
    if tr.Hit then
        view_pos = tr.HitPos 
    end

    //Переменные для отрисовки модели.
    local drawviewer = true
    local wep        = ply:GetActiveWeapon()

    //Проверка для прицеливания из оружия.
    if IsValid( wep ) and wep.CrossHairScope then
        view_pos = LerpVector( wep.IronSightsProgress, view_pos, pos )
        drawviewer = wep.IronSightsProgress < 0.9
    end

    //Таблица для параметров.
    local view = {

        origin     = view_pos,
        fov        = fov,
        angles     = view_angle,
        drawviewer = drawviewer

    }

    return view
end

hook.Add( "CalcView", "IDL_UI_ThridPresonCalcView", IDL_UI_ThridPresonCalcView )

local function IDL_UI_ThridPresonInputMouseApply( cmd, x, y, ang )

    local LPLY = LocalPlayer()

    //Проверка на состояние камеры.
    if not enable then 
        return 
    end

    //Проверка на состояние камеры в режиме noclip.
    if LPLY:GetMoveType() == MOVETYPE_NOCLIP or not hold_angle then 
        return 
    end


    //Переменные обновления угла камеры на основе движения мыши.
    hold_angle.p = math.Clamp( math.NormalizeAngle( hold_angle.p + y / 50 ), -90, 90 )
    hold_angle.y = math.NormalizeAngle( hold_angle.y - x / 50 )

    return true
end

hook.Add( "InputMouseApply", "IDL_UI_ThridPresonInputMouseApply", IDL_UI_ThridPresonInputMouseApply )

local function IDL_UI_ThridPresonCreateMove( cmd )
    
    local LPLY = LocalPlayer()

    //Проверка на состояние камеры.
    if not enable then 
        return 
    end

    //Проверка на состояние камеры в режиме noclip.
    if LPLY:GetMoveType() == MOVETYPE_NOCLIP or not hold_angle then 
        return 
    end

    //Переменная для получения вектора движения.
    local curVec = Vector( cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove() )

    //Вектор направления относительно камеры.
    curVec:Rotate( view_angle - hold_angle )
    
    //команды движения для обновления. 
    cmd:SetForwardMove( curVec.x )
    cmd:SetSideMove( curVec.y )
    cmd:SetUpMove( curVec.z )
end

hook.Add( "CreateMove", "IDL_UI_ThridPresonCreateMove", IDL_UI_ThridPresonCreateMove )

//Функция для включения и выключения камеры.
local function IDL_UI_ThridPresonEnable( name, old, new )
    enable = tobool( new )
end
cvars.AddChangeCallback("idl_thirdperson", IDL_UI_ThridPresonEnable)

//Функция для смещения камеры по X.
local function IDL_UI_ThridPresonX( name, old, new )
    x = Lerp( tonumber( new ), -40, -120 )
end
cvars.AddChangeCallback("idl_thirdperson_x", IDL_UI_ThridPresonX)

//Функция для смещения камеры по Y.
local function IDL_UI_ThridPresonY( name, old, new )
    y = Lerp( tonumber( new ), -40, 40 )
end
cvars.AddChangeCallback("idl_thirdperson_y", IDL_UI_ThridPresonY)

//Функция для смещения камеры по Z.
local function IDL_UI_ThridPresonZ( name, old, new )
    z = Lerp( tonumber( new ), -15, 15 )
end
cvars.AddChangeCallback("idl_thirdperson_z", IDL_UI_ThridPresonZ)

local function IDL_UI_ToggleThirdPerson()
    local IDLConVar = GetConVar( "idl_thirdperson" ):GetInt()
    LocalPlayer():ConCommand("idl_thirdperson "..( IDLConVar == 0 and 1 or 0 ))
end

local function KeyF2()

    if input.IsKeyDown( KEY_F2 ) and keyf2 then

        keyf2 = false

        IDL_UI_ToggleThirdPerson()

        timer.Simple( 0.2, function() keyf2 = true end )

    end

end

concommand.Add("cg_thirdperson", function( ply )

    local IDLConVar = GetConVar("idl_thirdperson"):GetInt()

    LocalPlayer():ConCommand( "idl_thirdperson " .. ( IDLConVar == 0 and 1 or 0 ) )

end)

hook.Add("Think", "IDL_ThirdPersonToggle", KeyF2)

cg_loggin_print("log", "thirdperson loaded")