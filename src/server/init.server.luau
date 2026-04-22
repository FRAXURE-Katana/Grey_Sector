-- 'script' is the Server script itself. 'Services' is a child of it.
local Services = script.Services

-- Require the modules using dot-notation so Luau's typechecker is happy
local GameLoopService = require(Services.GameLoopService)
local PlayerManagerService = require(Services.PlayerManagerService)

print("Initializing Server Systems...")

-- Start the services
PlayerManagerService:Start()
GameLoopService:Start()

print("Server Systems Running!")
