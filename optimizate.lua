local movementKeys = {
    [KEY_W] = true,
    [KEY_A] = true,
    [KEY_S] = true,
    [KEY_D] = true
}

local function ClearDecals()
  --  print("cleardecals") 
    client.Command("r_cleardecals", true)
end

local function CheckMovementKeys()
    for key, _ in pairs(movementKeys) do
        if input.IsButtonDown(key) then
            ClearDecals()
            return  
        end
    end
end

callbacks.Register("Draw", CheckMovementKeys)
