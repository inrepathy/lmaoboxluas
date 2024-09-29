local ImMenu = require("ImMenu")

callbacks.Register("Draw", "ImMenuExample", function()
    if ImMenu.Begin("tools") then
        if ImMenu.Button("Force Full Update") then
            clientstate.ForceFullUpdate() 
        end

        ImMenu.End()
    end
end)

