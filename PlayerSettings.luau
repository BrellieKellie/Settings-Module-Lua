-- Player Settings System
-- Made by @LunixHenry2040
-- July 2026


---------------------------- Services
local RunService = game:GetService("RunService")

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")


---------------------------- Lighting
local ColorCorrection : ColorCorrectionEffect = Lighting:WaitForChild("ColorCorrection")


---------------------------- Modules
-- Other Module Scripts
local RSModuleScripts = ReplicatedStorage.ModuleScripts
local PlayersModuleScripts = RSModuleScripts.Players
local PlayerManager = require(PlayersModuleScripts.PlayerFunctions.PlayerManager)


-- Module (Internal) 
local Data = require(script.Data)
local ValueRanges = Data.Constants.ValueRanges
local Bindables = Data.Bindables

local SettingsGui = require(script.Gui)

	
	
-- Module
local PlayerSettings = {}



---------------------------- Server

-- Run server settings handling
function PlayerSettings.InitializeServer()
	
	---------------------------- Player Added / Removing
	Players.PlayerAdded:Connect(function(Player)
		
		local PlrSettingsF, PlrSettings = Data.PlayerData.LoadPlayerSettingsData(Player)
		
		--------------------------------------------------------
		---------------------------- Player GUI
		local PlayerGui = Player.PlayerGui

		-- Sounds
		local GuiSounds = PlayerGui:WaitForChild("GuiSounds")
		local ButtonClickSound = GuiSounds:WaitForChild("ButtonClickSound")

		local function ChangeUiSfxEnabled()
			for i, Sound : Sound in GuiSounds:GetChildren() do
				Sound.Volume = PlrSettings.UiSfxEnabled.Value
			end
		end
		
		
		
		---------------------------- Setting Changed
		Bindables.SettingChanged.OnServerEvent:Connect(function(plr : Player, SettingName : string, InputUi : GuiObject, ChangeValue : number)

			---------------------------- Status Values / Identifiers
			local IsToggle = InputUi.Name == "Toggle" or InputUi.Name == "ToggleSwitch"
			local IsSlider = InputUi.Name == "DragButton" or InputUi.Parent.Name == "Slider"
			local IsTextBox = InputUi:IsA("TextBox")
			
			
			
			---------------------------- Setting functions

			-- Toggle a true/false setting.
			local function ChangeToggleSetting(SettingV)
				SettingV.Value = math.clamp(SettingV.Value, 0, 1)
				SettingV.Value = if SettingV.Value == 1 then 0 else 1
			end
			
			
			-- Set the setting depending on if the InputUi is a TextBox.
			local function SetTextBox(SettingV : ValueBase, ChangeValue : number)
				SettingV.Value = Data.ClampSettingValue(SettingV, ChangeValue, if not IsTextBox then true else false)
			end
			
			
			
			---------------------------- Set Setting and UI
			if IsToggle then
				ChangeToggleSetting(PlrSettings[SettingName])
				Bindables.VisualToggle:FireClient(Player, PlrSettings[SettingName], InputUi)
				
				
				Bindables.ChangeValueClient:FireClient(Player, "GlobalShadowsEnabled")
				Bindables.ChangeValueClient:FireClient(Player, "ColorCorrectionEnabled")
				
				
			elseif IsTextBox or IsSlider then
				SetTextBox(PlrSettings[SettingName], ChangeValue)
				Bindables.VisualToggle:FireClient(Player, PlrSettings[SettingName], InputUi)
				

				task.spawn(ChangeUiSfxEnabled)
				Bindables.ChangeValueClient:FireClient(Player, "FieldOfView")
				
				
			end
		end)
		

		---------------------------- Initialize
		task.spawn(ChangeUiSfxEnabled)
		
	end)	

	Players.PlayerRemoving:Connect(function(Player : Player, Reason : Enum.PlayerExitReason)
		Data.PlayerData.SavePlayerSettingsData(Player)
	end)
	
	
end



---------------------------- Client

function ClientManager(Player : Player)

	--------------------------------------------------------
	---------------------------- Player
	local PlayerGui = Player.PlayerGui
	local Camera = workspace.CurrentCamera

	local StatusValuesF = Player:WaitForChild('StatusValues')
	local StatusValues = {
		IsADS = StatusValuesF.IsADS,
		IsPlayerLocked = StatusValuesF.IsPlayerLocked,
	}


	---------------------------- Settings
	local PlayerSettingsF = Player:WaitForChild("settings")


	--------------------------------------------------------
	---------------------------- Toggled Settings Handling

	Bindables.ChangeValueClient.OnClientEvent:Connect(function(ValueName : string)
		if ValueName == "GlobalShadowsEnabled" then
			Lighting.GlobalShadows = PlayerSettingsF.GlobalShadowsEnabled.Value == 1
			
		elseif ValueName == "ColorCorrectionEnabled" then
			ColorCorrection.Enabled = PlayerSettingsF.ColorCorrectionEnabled.Value == 1
			
			
		elseif ValueName == "FieldOfView" then
			if StatusValues.IsPlayerLocked:GetAttribute("IsCameraLocked") or StatusValues.IsADS.Value then return end
			Camera.FieldOfView = PlayerSettingsF.FieldOfView.Value
			
		end
	end)


	---------------------------- Initialize Settings ; Set initial values
	Lighting.GlobalShadows = PlayerSettingsF.GlobalShadowsEnabled.Value == 1
	ColorCorrection.Enabled = PlayerSettingsF.ColorCorrectionEnabled.Value == 1

end



-- Run client settings handling
function PlayerSettings.InitializeClient(Player : Player, Gui : ScreenGui)

	--------------------------------------------------------
	---------------------------- Setup
	ClientManager(Player)
	SettingsGui.InitializeClient(Player, Gui)
	
end




return PlayerSettings
