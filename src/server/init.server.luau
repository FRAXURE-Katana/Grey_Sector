local Services = script.Services

local GameLoopService = require(Services.GameLoopService)
local PlayerManagerService = require(Services.PlayerManagerService)
local WeaponService = require(Services.WeaponService)
local LoadoutService = require(Services.LoadoutService)

print("Initializing Server Systems...")

PlayerManagerService:Start()
GameLoopService:Start()
WeaponService:Start()
LoadoutService:Start()

print("Server Systems Running!")
