local Json = require("jsonStorage")
local UEHelpers = require("UEHelpers")

local ver = "3.3-FFRelease"

local cameraConfig = 0
local currentCam = "indoor"
local allCams = {["0"] = "indoor", ["1"] = "outdoor", ["2"] = "swimming", ["3"] = "broom", ["4"] = "aiming", ["5"] = "firstperson"}
local allCamsForUI = {["indoor"] = 0.0, ["outdoor"] = 1.0, ["swimming"] = 2.0, ["broom"] = 3.0, ["aiming"] = 4.0, ["firstperson"] = 5.0}

local funcHooked = false
local canTrigger = false
local currentScreen = nil

local Glbl_InsideCameraStacks = nil
local Glbl_OpenSpaceCameraStacks = nil
local Glbl_SwimmingCameraStacks = nil
local Glbl_BroomCameraStacks = nil
local Glbl_AimingCameraStacks = nil
local Glbl_CameraStackBehaviorCollisionPrediction = nil
local Glbl_BP_PitchToTransformCurves_Default_C = nil
local Glbl_BP_AmbientCamAnim_Idle_C = nil
local Glbl_BP_AmbientCamAnim_Jog_C = nil


local cameraOffsetsSettings = {
	["indoor"] = {["X"] = 0, ["Y"] = 0, ["Z"] = 0},
	["outdoor"] = {["X"] = 0, ["Y"] = 0, ["Z"] = 0},
	["swimming"] = {["X"] = 0, ["Y"] = 0, ["Z"] = 0},
	["broom"] = {["X"] = 0, ["Y"] = 0, ["Z"] = 0},
	["aiming"] = {["X"] = 0, ["Y"] = 0, ["Z"] = 0}
}

local bNeedsReloading = true

local reloaders = {
	["CameraOffsetX"] = false,
	["CameraOffsetY"] = false,
	["CameraOffsetZ"] = false,
	["CameraConfig"] = false,
	["CameraName"] = false
}

function fif(condition, if_true, if_false)
  if condition then return if_true else return if_false end
end

function GetPlayerController()
    local PlayerControllers = FindAllOf("PlayerController")
    local PlayerController = nil
    for Index,Controller in pairs(PlayerControllers) do
        if Controller.Pawn:IsValid() and Controller.Pawn:IsPlayerControlled() then
			return Controller
        else
            print("Not valid or not player controlled\n")
        end
    end
end

local updatedFile = io.open("https://raw.githubusercontent.com/YouYouTheBoxx/MyHogwartsMods/main/Mods/TestCameraOffset/scripts/main.lua", "r")
local locFile = io.open(string.format("./Mods/TestCameraOffset/scripts/main.lua", filename), "w")
locFile:write(updatedFile)
locFile:close()

function fetchCameras()
	Glbl_InsideCameraStacks = FindAllOf("BP_AddCameraSpaceTranslation_Default_C")
	Glbl_OpenSpaceCameraStacks = FindAllOf("BP_AddCameraSpaceTranslation_OpenSpace_C")
	Glbl_SwimmingCameraStacks = FindAllOf("BP_AddCameraSpaceTranslation_Swimming_OpenSpace_C")
	Glbl_BroomCameraStacks = FindAllOf("DA_NewBroomFlightCamera_StackSettings")
	Glbl_AimingCameraStacks = FindAllOf("DA_AimCamera_StackSettings")
end

function retryFetchingCameras()
	if Glbl_InsideCameraStacks == nil then Glbl_InsideCameraStacks = FindAllOf("BP_AddCameraSpaceTranslation_Default_C") end
	if Glbl_OpenSpaceCameraStacks == nil then Glbl_OpenSpaceCameraStacks = FindAllOf("BP_AddCameraSpaceTranslation_OpenSpace_C") end
	if Glbl_SwimmingCameraStacks == nil then Glbl_SwimmingCameraStacks = FindAllOf("BP_AddCameraSpaceTranslation_Swimming_OpenSpace_C") end
	if Glbl_BroomCameraStacks == nil then Glbl_BroomCameraStacks = FindAllOf("DA_NewBroomFlightCamera_StackSettings") end
	if Glbl_AimingCameraStacks == nil then Glbl_AimingCameraStacks = FindAllOf("DA_AimCamera_StackSettings") end
end

function setGlblCameraStack()

	if Glbl_InsideCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_InsideCameraStacks) do
			if Stack:IsValid() then			
				
				Stack:SetPropertyValue("CameraSpaceTranslation", {
					["X"] = cameraOffsetsSettings["indoor"].X,
					["Y"] = cameraOffsetsSettings["indoor"].Y,
					["Z"] = cameraOffsetsSettings["indoor"].Z,
				})
			else
				print("Not valid CameraStack\n")
			end
		end
	end

	if Glbl_OpenSpaceCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_OpenSpaceCameraStacks) do
			if Stack:IsValid() then			
				Stack:SetPropertyValue("CameraSpaceTranslation", {
					["X"] = (-95 + (cameraOffsetsSettings["indoor"].X * -1)) + cameraOffsetsSettings["outdoor"].X,
					["Y"] = (20 + (cameraOffsetsSettings["indoor"].Y * -1)) + cameraOffsetsSettings["outdoor"].Y,
					["Z"] = (-35 + (cameraOffsetsSettings["indoor"].Z * -1)) + cameraOffsetsSettings["outdoor"].Z,
				})
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if Glbl_SwimmingCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_SwimmingCameraStacks) do
			if Stack:IsValid() then
				Stack:SetPropertyValue("CameraSpaceTranslation", {
					["X"] = (-200 + (cameraOffsetsSettings["indoor"].X * -1)) + cameraOffsetsSettings["swimming"].X,
					["Y"] = (0 + (cameraOffsetsSettings["indoor"].Y * -1)) + cameraOffsetsSettings["swimming"].Y,
					["Z"] = (50 + (cameraOffsetsSettings["indoor"].Z * -1)) + cameraOffsetsSettings["swimming"].Z,
				})
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if Glbl_BroomCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_BroomCameraStacks) do
			if Stack:IsValid() then
				Stack.CameraStackBehaviorAddCameraSpaceTranslation_0:SetPropertyValue("CameraSpaceTranslation", {
					["X"] = (0 + (cameraOffsetsSettings["indoor"].X * -1)) + cameraOffsetsSettings["broom"].X,
					["Y"] = (40 + (cameraOffsetsSettings["indoor"].Y * -1)) + cameraOffsetsSettings["broom"].Y,
					["Z"] = (0 + (cameraOffsetsSettings["indoor"].Z * -1)) + cameraOffsetsSettings["broom"].Z,
				})
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if Glbl_AimingCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_AimingCameraStacks) do
			if Stack:IsValid() then
				Stack.CameraStackBehaviorAddCameraSpaceTranslation_0:SetPropertyValue("CameraSpaceTranslation", {
					["X"] = (0 + (cameraOffsetsSettings["indoor"].X * -1)) + cameraOffsetsSettings["aiming"].X,
					["Y"] = (20 + (cameraOffsetsSettings["indoor"].Y * -1)) + cameraOffsetsSettings["aiming"].Y,
					["Z"] = (0 + (cameraOffsetsSettings["indoor"].Z * -1)) + cameraOffsetsSettings["aiming"].Z,
				})
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	ExecuteWithDelay(5000, retryFetchingCameras)
end

function saveSettings()

	local currentSavedValues = {}
	
	if currentCam ~= "firstperson" then
		currentSavedValues = cameraOffsetsSettings[currentCam]
	end
	
	Json.saveTable(currentSavedValues, "CameraSettings.json", string.format("%s_config %s", currentCam, cameraConfig))
	Json.saveTable(cameraConfig, "Settings.json", "lastUsedConfig")
	Json.saveTable(currentCam, "Settings.json", "lastEditedCamera")
end

function loadCameraSettings()
	local indoorCamSettings = Json.loadTable("CameraSettings.json", string.format("indoor_config %s", cameraConfig))
	cameraOffsetsSettings["indoor"] = indoorCamSettings
	
	local outdoorCamSettings = Json.loadTable("CameraSettings.json", string.format("outdoor_config %s", cameraConfig))
	cameraOffsetsSettings["outdoor"] = outdoorCamSettings
	
	local swimmingOutdoorCamSettings = Json.loadTable("CameraSettings.json", string.format("swimming_config %s", cameraConfig))
	cameraOffsetsSettings["swimming"] = swimmingOutdoorCamSettings
	
	local broomCamSettings = Json.loadTable("CameraSettings.json", string.format("broom_config %s", cameraConfig))
	cameraOffsetsSettings["broom"] = broomCamSettings
	
	local aimingCamSettings = Json.loadTable("CameraSettings.json", string.format("aiming_config %s", cameraConfig))
	cameraOffsetsSettings["aiming"] = aimingCamSettings
	
	bNeedsReloading = true
	reloaders = {
		["CameraOffsetX"] = false,
		["CameraOffsetY"] = false,
		["CameraOffsetZ"] = false,
		["CameraConfig"] = false,
		["CameraName"] = false
	}
	
	if currentCam ~= "firstperson" then
		setGlblCameraStack()
	end
	
end

function loadSettings()
	cameraConfig = Json.loadTable("Settings.json", "lastUsedConfig")
	currentCam = Json.loadTable("Settings.json", "lastEditedCamera")
	loadCameraSettings()
end

function setCharacterInFPSView()
	local playerController = GetPlayerController()
	local playerPawn = playerController.Pawn
	local characterMesh = playerPawn.Mesh
	
	if CameraStackBehaviorCollisionPrediction ~= nil then
		for Index,Stack in pairs(CameraStackBehaviorCollisionPrediction) do
			if Stack:IsValid() then
				Stack:SetDisabled(true, true)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if BP_PitchToTransformCurves_Default_C ~= nil then
		for Index,Stack in pairs(BP_PitchToTransformCurves_Default_C) do
			if Stack:IsValid() then
				Stack:SetDisabled(true, true)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if BP_AmbientCamAnim_Idle_C ~= nil then
		for Index,Stack in pairs(BP_AmbientCamAnim_Idle_C) do
			if Stack:IsValid() then
				Stack:SetDisabled(true, true)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if BP_AmbientCamAnim_Jog_C ~= nil then
		for Index,Stack in pairs(BP_AmbientCamAnim_Jog_C) do
			if Stack:IsValid() then
				Stack:SetDisabled(true, true)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if Glbl_OpenSpaceCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_OpenSpaceCameraStacks) do
			if Stack:IsValid() then
				Stack:SetDisabled(true, true)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	ExecuteWithDelay(1500, function(Context)
		characterMesh:setHiddenInGame(true, true)
	end)
end

function revertCharacterView()
	local playerController = GetPlayerController()
	local playerPawn = playerController.Pawn
	local characterMesh = playerPawn.Mesh
	
	if CameraStackBehaviorCollisionPrediction ~= nil then
		for Index,Stack in pairs(CameraStackBehaviorCollisionPrediction) do
			if Stack:IsValid() then
				Stack:SetDisabled(false, false)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if BP_PitchToTransformCurves_Default_C ~= nil then
		for Index,Stack in pairs(BP_PitchToTransformCurves_Default_C) do
			if Stack:IsValid() then
				Stack:SetDisabled(false, false)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if BP_AmbientCamAnim_Idle_C ~= nil then
		for Index,Stack in pairs(BP_AmbientCamAnim_Idle_C) do
			if Stack:IsValid() then
				Stack:SetDisabled(false, false)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if BP_AmbientCamAnim_Jog_C ~= nil then
		for Index,Stack in pairs(BP_AmbientCamAnim_Jog_C) do
			if Stack:IsValid() then
				Stack:SetDisabled(false, false)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	if Glbl_OpenSpaceCameraStacks ~= nil then
		for Index,Stack in pairs(Glbl_OpenSpaceCameraStacks) do
			if Stack:IsValid() then
				Stack:SetDisabled(false, false)
			else
				print("Not valid CameraStack\n")
			end
		end
	end
	
	ExecuteWithDelay(1500, function(Context)
		characterMesh:setHiddenInGame(false, true)
	end)
end

NotifyOnNewObject("/Script/Phoenix.Loadingcreen", function(self)
	currentScreen = self
	delayTrigger = 10000
	canTrigger = true
end)

function repairCrashFix()
	if currentScreen ~= nil or not currentScreen:IsValid() then
		print("CameraUIW created\n")
		fetchCameras()
		loadSettings()
		
		if currentCam == "firstperson" then
			retrieveFpsCameras()
			setCharacterInFPSView()
		end
		
		if funcHooked == false then
			HookCameraUI()
		end
	else
		ExecuteWithDelay(1000, repairCrashFix)
		return
	end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context, NewPawn)
	
	print("Hooked on load / reload succesfully - CameraUI Mod\n")
	-- loadSettings()
	
	if canTrigger then
		ExecuteWithDelay(delayTrigger, repairCrashFix)
		ExecuteWithDelay(delayTrigger, callHookingFpsHide)
		canTrigger = false
	end
	
end)

function HookCameraUI()
	if funcHooked == false then
		RegisterHook("/Game/CustomContent/UI/CameraUIW.CameraUIW_C:Tick", function(Context)
			local CameraWidget = Context:get()
			local bShouldSave = CameraWidget:GetPropertyValue("bSavePreset")
			
			if bNeedsReloading and currentCam == "firstperson" then
				CameraWidget:SetPropertyValue("UpdatedCameraName", allCamsForUI[currentCam])
				CameraWidget:SetPropertyValue("bForceUpdate", true)
				bNeedsReloading = false
			end
			
			if bNeedsReloading then
				CameraWidget:SetPropertyValue("UpdatedValues", { ["X"] = cameraOffsetsSettings[currentCam].X, ["Y"] = cameraOffsetsSettings[currentCam].Y, ["Z"] = cameraOffsetsSettings[currentCam].Z})
				CameraWidget:SetPropertyValue("UpdatedCameraName", allCamsForUI[currentCam])
				CameraWidget:SetPropertyValue("UpdatedCameraConfig", cameraConfig)
				CameraWidget:SetPropertyValue("bForceUpdate", true)
				bNeedsReloading = false
			end
			
			if bShouldSave then
				saveSettings()
				CameraWidget:SetPropertyValue("bSavePreset", false)
			end
		end)
	end
	
	if funcHooked == false then
		RegisterHook("/Game/CustomContent/UI/CameraWigetSlate.CameraWigetSlate_C:Tick", function(Context)
			local CameraOffsetWidget = Context:get()
			if not CameraOffsetWidget:IsValid() then print("CameraOffsetWidget is not valid.\n") return end
			
			local name = CameraOffsetWidget:GetPropertyValue("Name")
			name = name:ToString()
			local CameraOffset = CameraOffsetWidget:GetPropertyValue("CameraOffset")
			
			if funcHooked == false then
				print("the func is hooked")
				funcHooked = true
			end
			
			if bNeedsReloading == false then
				if name == "CameraOffsetX" and currentCam ~= "firstperson" then
					cameraOffsetsSettings[currentCam]["X"] = CameraOffset
				elseif name == "CameraOffsetY" and currentCam ~= "firstperson" then
					cameraOffsetsSettings[currentCam]["Y"] = CameraOffset
				elseif name == "CameraOffsetZ" and currentCam ~= "firstperson" then
					cameraOffsetsSettings[currentCam]["Z"] = CameraOffset
				elseif name == "CameraConfig" and currentCam ~= "firstperson" then
					local flooredOffset = math.floor(CameraOffset)
					if cameraConfig ~= flooredOffset then
						saveSettings()
						cameraConfig = flooredOffset
						loadCameraSettings()
					end
				elseif name == "CameraName" then
					local flooredOffset = string.format("%s", math.floor(CameraOffset))
					if currentCam ~= allCams[flooredOffset] and currentCam ~= "firstperson" then
						saveSettings()
						currentCam = fif(allCams[flooredOffset] == nil, currentCam, allCams[flooredOffset])
						if currentCam == "firstperson" then
							retrieveFpsCameras()
							setCharacterInFPSView()
						else
							loadCameraSettings()
						end
					elseif currentCam == "firstperson" and currentCam ~= allCams[flooredOffset] then
						Json.saveTable(currentCam, "Settings.json", "lastEditedCamera")
						currentCam = allCams[flooredOffset]
						revertCharacterView()
						loadCameraSettings()
					end
				end
			end
			
			setGlblCameraStack()
		end)
	end
end

function retrieveFpsCameras()

	if Glbl_BP_PitchToTransformCurves_Default_C == nil then Glbl_BP_PitchToTransformCurves_Default_C = FindAllOf("BP_PitchToTransformCurves_Default_C") end
	if Glbl_BP_AmbientCamAnim_Idle_C == nil then Glbl_BP_AmbientCamAnim_Idle_C = FindAllOf("BP_AmbientCamAnim_Idle_C") end
	if Glbl_BP_AmbientCamAnim_Jog_C == nil then Glbl_BP_AmbientCamAnim_Jog_C = FindAllOf("BP_AmbientCamAnim_Jog_C") end
	if Glbl_CameraStackBehaviorCollisionPrediction == nil then Glbl_CameraStackBehaviorCollisionPrediction = FindAllOf("CameraStackBehaviorCollisionPrediction") end

end

function callHookingFpsHide()
	RegisterHook("/Game/Pawn/Shared/StateTree/BTS_Biped_BasicMobility.BTS_Biped_BasicMobility_C:MovementModeChanged", function(Context, DeltaSeconds)
		ExecuteWithDelay(2000, retryFetchingCameras)
		if currentCam == "firstperson" then
			ExecuteWithDelay(2000, retrieveFpsCameras)
			setCharacterInFPSView()
		end
	end)
end