local function onCreateMove(cmd)
    local me = entities.GetLocalPlayer()
    
    if me ~= nil then
        local wpn = me:GetPropEntity("m_hActiveWeapon")
        
        if wpn ~= nil then
            if warp.CanWarp() then
                warp.TriggerCharge()  
                warp.TriggerWarp()    
            end
        end
    end
end

callbacks.Register("CreateMove", onCreateMove)
