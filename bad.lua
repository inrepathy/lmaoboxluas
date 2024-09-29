local ImMenu = require("ImMenu")


local isMenuOpen = false 
local lastToggleTime = 0   

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
end

callbacks.Register("Draw", "NonMenuDraw", NonMenuDraw)

callbacks.Register("Draw", "ImMenuExample", function()
    if isMenuOpen then
        if ImMenu.Begin("Tools") then
            if ImMenu.Button("Force Full Update") then
                clientstate.ForceFullUpdate()  
            end

            ImMenu.End()
        end
    end
end)


