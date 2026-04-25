local Services = script.Services

local GameLoopService = require(Services.GameLoopService)
local PlayerManagerService = require(Services.PlayerManagerService)
local WeaponService = require(Services.WeaponService)
local LoadoutService = require(Services.LoadoutService)
local NPCService = require(Services.NPCService) -- NEW

print("Initializing Server Systems...")

PlayerManagerService:Start()
GameLoopService:Start()
WeaponService:Start()
LoadoutService:Start()
NPCService:Start() -- NEW

print("Server Systems Running!")
