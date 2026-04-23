local Services = script.Services

local GameLoopService = require(Services.GameLoopService)
local PlayerManagerService = require(Services.PlayerManagerService)
local WeaponService = require(Services.WeaponService)

print("Initializing Server Systems...")

PlayerManagerService:Start()
GameLoopService:Start()
WeaponService:Start()

print("Server Systems Running!")
