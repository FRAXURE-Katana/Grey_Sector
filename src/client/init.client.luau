local Controllers = script:WaitForChild("Controllers")

-- Require the modules
local CameraController = require(Controllers.CameraController)
local WeaponController = require(Controllers.WeaponController)
local MovementController = require(Controllers.MovementController) -- NEW

print("Initializing Client Systems...")

-- Start the controllers
CameraController:Start()
WeaponController:Start()
MovementController:Start() -- NEW

print("Client Systems Running!")
