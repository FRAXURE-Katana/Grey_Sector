local Controllers = script:WaitForChild("Controllers")

-- Require the modules
local CameraController = require(Controllers.CameraController)
local WeaponController = require(Controllers.WeaponController)

print("Initializing Client Systems...")

-- Start the controllers
CameraController:Start()
WeaponController:Start()

print("Client Systems Running!")
