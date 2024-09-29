local ImMenu = require("ImMenu")

local isMenuOpen = false 
local lastToggleTime = 0   
local enableBunnyHop = false  

local hitbox_id = 3  
local max_records = 1 
local disappear_time = 3 

local tracer = true 
local hitbox_surrounding_box = false

local hitPos = {}

-- Add these two variables for aspect ratio control
local adjustAspectRatio = false
local aspectRatioValue = 1.0

local function toggleMenu()
    isMenuOpen = not isMenuOpen  
end

local function NonMenuDraw()
    local currentTime = globals.CurTime() * 1000 

    if (input.IsButtonPressed(KEY_END) or input.IsButtonPressed(KEY_INSERT) or input.IsButtonPressed(KEY_F11)) and 
       (currentTime - lastToggleTime >= 300) then
        toggleMenu()
        lastToggleTime = currentTime 
    end

    -- Register aspect ratio adjustment callback
    if adjustAspectRatio then
        callbacks.Register("RenderView", function(view)
            view.aspectRatio = aspectRatioValue
        end)
    end
end

local function PlayerHurtEvent(event)
    if event:GetName() == 'player_hurt' then
        local localPlayer = entities.GetLocalPlayer()
        local victim = entities.GetByUserID(event:GetInt("userid"))
        local attacker = entities.GetByUserID(event:GetInt("attacker"))

        if attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex() then
            return
        end

        local startPos = localPlayer:GetAbsOrigin() + localPlayer:GetPropVector("localdata", "m_vecViewOffset[0]")
        local hitbox = victim:GetHitboxes()[hitbox_id]
        local endPos = (hitbox[1] + hitbox[2]) / 2
        local box = victim:HitboxSurroundingBox()
        table.insert(hitPos, 1, {startPos, endPos, box, globals.RealTime()})

        if #hitPos > max_records then 
            table.remove(hitPos)
        end
    end
end

callbacks.Register("FireGameEvent", "PlayerHurtEvent", PlayerHurtEvent)

local function Draw3DBox(size, pos)
    local halfSize = size / 2
    local corners = {
        Vector3(-halfSize, -halfSize, -halfSize),
        Vector3(halfSize, -halfSize, -halfSize),
        Vector3(halfSize, halfSize, -halfSize),
        Vector3(-halfSize, halfSize, -halfSize),
        Vector3(-halfSize, -halfSize, halfSize),
        Vector3(halfSize, -halfSize, halfSize),
        Vector3(halfSize, halfSize, halfSize),
        Vector3(-halfSize, halfSize, halfSize)
    }
    
    local screenPositions = {}
    for _, cornerPos in ipairs(corners) do
        local worldPos = pos + cornerPos
        local screenPos = client.WorldToScreen(worldPos)
        if screenPos then
            table.insert(screenPositions, { x = screenPos[1], y = screenPos[2] })
        end
    end

    local linesToDraw = {
        {1, 2}, {2, 3}, {3, 4}, {4, 1},
        {5, 6}, {6, 7}, {7, 8}, {8, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }
    
    for _, line in ipairs(linesToDraw) do
        local p1, p2 = screenPositions[line[1]], screenPositions[line[2]]
        if p1 and p2 then
            draw.Line(p1.x, p1.y, p2.x, p2.y)
        end
    end
end

local function PlayerHurtEventDraw()
    local currentTime = globals.RealTime()
    for i, v in pairs(hitPos) do 
        if currentTime - v[4] > disappear_time then
            table.remove(hitPos, i)
        else
            draw.Color(255, 255, 255, 255)
            if tracer then 
                local startPos = v[1]
                local endPos = v[2]
                local w2s_startPos = client.WorldToScreen(startPos)
                local w2s_endPos = client.WorldToScreen(endPos)
                Draw3DBox(10, endPos)
                if w2s_startPos and w2s_endPos then 
                    draw.Line(w2s_startPos[1], w2s_startPos[2], w2s_endPos[1], w2s_endPos[2])
                end
            end
            
            if hitbox_surrounding_box then 
                local hitboxes = v[3]
                local min = hitboxes[1]
                local max = hitboxes[2]
                local vertices = {
                    Vector3(min.x, min.y, min.z),
                    Vector3(min.x, max.y, min.z),
                    Vector3(max.x, max.y, min.z),
                    Vector3(max.x, min.y, min.z),
                    Vector3(min.x, min.y, max.z),
                    Vector3(min.x, max.y, max.z),
                    Vector3(max.x, max.y, max.z),
                    Vector3(max.x, min.y, max.z)
                }
                
                local screenVertices = {}
                for j, vertex in ipairs(vertices) do
                    local screenPos = client.WorldToScreen(vertex)
                    if screenPos then
                        screenVertices[j] = {x = screenPos[1], y = screenPos[2]}
                    end
                end
                
                for j = 1, 4 do
                    local vertex1 = screenVertices[j]
                    local vertex2 = screenVertices[j % 4 + 1]
                    local vertex3 = screenVertices[j + 4]
                    local vertex4 = screenVertices[(j + 4) % 4 + 5]
                    if vertex1 and vertex2 and vertex3 and vertex4 then
                        draw.Line(vertex1.x, vertex1.y, vertex2.x, vertex2.y)
                        draw.Line(vertex3.x, vertex3.y, vertex4.x, vertex4.y)
                    end
                end
                
                for j = 1, 4 do
                    local vertex1 = screenVertices[j]
                    local vertex2 = screenVertices[j + 4]
                    if vertex1 and vertex2 then
                        draw.Line(vertex1.x, vertex1.y, vertex2.x, vertex2.y)
                    end
                end           
            end
        end
    end
end

callbacks.Register("Draw", "PlayerHurtEventDraw", PlayerHurtEventDraw)

callbacks.Register("Draw", "ImMenuExample", function()
    if isMenuOpen then
        if ImMenu.Begin("Tools") then
            enableBunnyHop = ImMenu.Checkbox("Enable Bunny Hop", enableBunnyHop)
            tracer = ImMenu.Checkbox("Enable Tracer", tracer)
            hitbox_surrounding_box = ImMenu.Checkbox("Enable Hitbox Surrounding Box", hitbox_surrounding_box)

            adjustAspectRatio = ImMenu.Checkbox("Adjust Aspect Ratio", adjustAspectRatio)

            if adjustAspectRatio then
                aspectRatioValue = ImMenu.Slider("Aspect Ratio Value", aspectRatioValue, 0.5, 2.0) 
            end

            if ImMenu.Button("Force Full Update") then
                clientstate.ForceFullUpdate()  
            end
            
            local currentTime = os.date("*t")
            local hours = currentTime.hour
            local minutes = currentTime.min
            local seconds = currentTime.sec
            ImMenu.Text(string.format("Current Time: %02d:%02d:%02d", hours, minutes, seconds))

            ImMenu.End()
        end
    end
end)

callbacks.Register("Draw", "NonMenuDraw", NonMenuDraw)
