-- Player Settings System
-- Made by @LunixHenry2040
-- July 2026


---------------------------- Services
local RunService = game:GetService("RunService")

local DataStoreService = game:GetService("DataStoreService")


---------------------------- Module
local PlayerSettingsModuleScript : ModuleScript = script.Parent

local Data = {}


---------------------------- Constant Data

-- Module Bindables
local ModuleBindablesF : Folder = PlayerSettingsModuleScript.Bindables
Data.Bindables = {
	SettingChanged = ModuleBindablesF.SettingChanged,
	VisualToggle = ModuleBindablesF.VisualToggle,

	ChangeValueClient = ModuleBindablesF.ChangeValueClient,
}


-- Data
Data.Constants = {
	
	------------------ Blur
	MenuOpenBlur = 20,
	MenuCloseBlur = 0,
	
	------------------ Image Ids 
	-- Topbar Button
	SettingsOpenImage = "rbxassetid://11956055886",
	SettingsCloseImage = "rbxassetid://11956055886",

	-- Toggle Switch
	ToggleOnImage = "rbxassetid://17835179616",
	ToggleOffImage = "rbxassetid://17835224461",
	
	
	------------------ Value Ranges
	ValueRanges = {
		FieldOfView = {Min = 40, Default = 70, Max = 120},
		BobbingStrength = {Min = 0, Default = 1, Max = 6},

		AutoShootDistance = {Min = 0, Default = 200, Max = 900},

		MusicEnabled = {Min = 0, Default = 0.2, Max = 10},
		UiSfxEnabled = {Min = 0, Default = 0.2, Max = 10},
	},
	
}


-- Settings for the Settings
Data.SettingsDescs = {
	---------- Misc
	WelcomeDesc = "Welcome! Hover or tap on the name of a setting to display information about it.",
	
	
	---------- Settings
	-- Display
	MotionBlurEnabled = "Motion Blur: When on, makes a blur effect whenever you swing your camera at a fast speed. [Turning off increases peformance]",
	GlobalShadowsEnabled = "(Global) Shadows: whether or not shadows appear in the environment. [Turning off increases performance]",
	FieldOfView = "(Camera) Field of View: How wide the camera can see.",
	BobbingStrength = "(Camera) Bobbing Strength: How strong the camera bobbles based on animations. [CAUTION: Strong bobbing may cause motion sickness for sensitive users.]",
	SimplifiedMoneyDisplayEnabled = "Simplified Money Display: When on, the number in the money display will be shortened. For example, 2945 will be 2.94K, and 6384543 will be 6.38M.",
	ColorCorrectionEnabled = 'Color Correction: Changes the looks of the graphics, making it more saturated and contrasted. [Does not affect performance]',
	
	-- Gameplay
	AutoShootEnabled = "Auto Shoot [Mobile Only]: Automatically shoot by hovering the crosshair over the enemy.",
	AutoShootDistance = "Auto Shoot Distance [Mobile Only]: When auto shoot is on, determine how far from the camera to detect for an enemy.",
	
	-- Sound
	MusicEnabled = "Music: Plays in-game music at the specified volume.",
	UiSfxEnabled = "UI SFX: Interface play sounds when interacted with at the specified volume.",
	SoundReverbEnabled = "Sound Reverb: When on, sounds will reverberate (echo) base on where your camera is. [Does not affect performance]",
	
	-- Other
	BroadcastBadgeAwardsEnabled = "Badge Awards: If on, the Server sends a message in the chat telling everyone you've been awarded a badge!",
	BroadcastLevelUpsEnabled = "Level Ups: If on, the Server sends a message in the chat telling everyone in the server that you've leveled up!",
}


-- Settings list for all player settings.
Data.SettingsList = {
	
	-- Display
	MotionBlurEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Display"},
	GlobalShadowsEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Display"},
	FieldOfView = {ValueType = "number", ChangeType = {"Slider", "TextBox"}, Category = "Display"},
	BobbingStrength = {ValueType = "number", ChangeType = {"Slider", "TextBox"}, Category = "Display"},
	SimplifiedMoneyDisplayEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Display"},
	ColorCorrectionEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Display"},
	
	-- Gameplay
	AutoShootEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Gameplay"},
	AutoShootDistance = {ValueType = "number", ChangeType = {"Slider", "TextBox"}, Category = "Gameplay"},
	
	-- Sound
	MusicEnabled = {ValueType = "number", ChangeType = {"Slider", "TextBox"}, Category = "Sound"},
	UiSfxEnabled = {ValueType = "number", ChangeType = {"Slider", "TextBox"}, Category = "Sound"},
	SoundReverbEnabled = {ValueType = "number", ChangeType = {"Toggle"}},
	
	-- Other
	BroadcastBadgeAwardsEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Other"},
	BroadcastLevelUpsEnabled = {ValueType = "number", ChangeType = {"Toggle"}, Category = "Other"},
}



---------------------------- Formatting / Value Changing

-- Format a value for a setting. Returns {FormattedValue : string}
function Data.FormatSettingValue(SettingInstance : ValueBase)
	------------------ Type Check
	if not SettingInstance then return end
	
	local Value = SettingInstance.Value
	
	------------------ Format
	local FormatList = {
		FieldOfView = tostring(string.format("%.02f", (math.round(Value * 100)) / 100)).."°",
		BobbingStrength = tostring(string.format("%.02f", (math.round(Value * 100)) / 100)),
		
		AutoShootDistance = tostring(Value).." Studs",
		
		MusicEnabled = tostring(string.format("%.02f", (math.round(Value * 100)) / 100)),
		UiSfxEnabled = tostring(string.format("%.02f", (math.round(Value * 100)) / 100)),
	}
	
	local FormattedValue = FormatList[SettingInstance.Name]
	
	------------------ Return
	if not FormattedValue then return tostring(Value) end
	return FormattedValue
end



-- Return a value between the setting's min and max values. Returns {Value : number}
function Data.ClampSettingValue(SettingInstance : ValueBase, ChangeValue : number, IsPercentageOfRange : boolean)
	
	------------------- Safety
	if not SettingInstance or not ChangeValue or not Data.Constants.ValueRanges[SettingInstance.Name] then warn("Failed to clamp setting value, missing or invalid arguments: ", SettingInstance, ChangeValue, IsPercentageOfRange) return end
	
	
	------------------- Set ClampedValue
	local ClampedValue = 
		if IsPercentageOfRange then
			Data.Constants.ValueRanges[SettingInstance.Name].Min + ((Data.Constants.ValueRanges[SettingInstance.Name].Max - Data.Constants.ValueRanges[SettingInstance.Name].Min) * ChangeValue)
		else
			math.clamp(ChangeValue, Data.Constants.ValueRanges[SettingInstance.Name].Min, Data.Constants.ValueRanges[SettingInstance.Name].Max)
	
	return ClampedValue
end


---------------------------- Dynamic Data / Data Return Functions
Data.PlayerData = {}


-- Get the player's settings folder and values. Returns {PlrSettingsF : Folder, PlrSettings : table}
function Data.PlayerData.GetSettingsValues(Player : Player)

	if not Player then warn("Failed to get player settings values, missing player argument: ", Player) return end
	
	---------------------------- Player Settings
	local PlrSettingsF = Player:FindFirstChild("settings")
	local PlrSettings = {}
	
	if not PlrSettingsF then warn("Failed to get player settings folder for player: ", Player) return end
	
	for i, Setting : ValueBase in PlrSettingsF:GetChildren() do
		PlrSettings[Setting.Name] = Setting
	end
	
	-- Run Away! Hahaha
	return PlrSettingsF, PlrSettings
end


local function CreateValue(ClassName : string, Name : string, InitialValue : any, TargetParent : Instance)
	local ValueBase = Instance.new(ClassName) ValueBase.Name = Name ValueBase.Value = InitialValue ValueBase.Parent = TargetParent
	return ValueBase
end


-- Get the data for player settings and handles DataStore. Server-sided. Returns {PlrSettingsF : Folder, PlrSettings : table}
function Data.PlayerData.LoadPlayerSettingsData(Player : Player)

	if not Player then warn("Failed to get player settings data, missing player argument: ", Player) return end
	
	---------------------------- DataStore
	local SettingsDataStore = DataStoreService:GetDataStore("SettingsDataStore")
	
	
	-------------------------------------------------------- Data
	---------------------------- Player Settings
	local PlrSettingsF = Instance.new("Folder") PlrSettingsF.Name = "settings" PlrSettingsF.Parent = Player
	
	local PlrSettings = {
		-- Display Settings
		MotionBlurEnabled = CreateValue("IntValue", "MotionBlurEnabled", 1, PlrSettingsF),
		GlobalShadowsEnabled = CreateValue("IntValue", "GlobalShadowsEnabled", 1, PlrSettingsF),
		FieldOfView = CreateValue("NumberValue", "FieldOfView", 80, PlrSettingsF),
		BobbingStrength = CreateValue("NumberValue", "BobbingStrength", 1, PlrSettingsF),
		ColorCorrectionEnabled = CreateValue("IntValue", "ColorCorrectionEnabled", 1, PlrSettingsF),
		SimplifiedMoneyDisplayEnabled = CreateValue("IntValue", "SimplifiedMoneyDisplayEnabled", 1, PlrSettingsF),


		-- Gameplay Settings
		AutoShootEnabled = CreateValue("IntValue", "AutoShootEnabled", 1, PlrSettingsF),
		AutoShootDistance = CreateValue("IntValue", "AutoShootDistance", 1, PlrSettingsF),


		-- Sounds Settings
		MusicEnabled = CreateValue("NumberValue", "MusicEnabled", 0.2, PlrSettingsF),
		UiSfxEnabled = CreateValue("NumberValue", "UiSfxEnabled", 0.2, PlrSettingsF),
		SoundReverbEnabled = CreateValue("IntValue", "SoundReverbEnabled", 1, PlrSettingsF),


		-- Other Settings
		BroadcastBadgeAwardsEnabled = CreateValue("IntValue", "BroadcastBadgeAwardsEnabled", 1, PlrSettingsF),
		BroadcastLevelUpsEnabled = CreateValue("IntValue", "BroadcastLevelUpsEnabled", 1, PlrSettingsF),
	}
	

	---------------------------- Get DataList
	local DataList = SettingsDataStore:GetAsync(Player.UserId)
	
	local Success, Result = pcall(function()
		if DataList then
			for SettingName : number, DataValue : any in DataList do
				if typeof(SettingName) == "string" and DataValue then
					PlrSettings[SettingName].Value = DataValue
				end
			end

		else 
			warn("No PlayerSettings DataStore found for UserId: ", Player.UserId, "; most likely new UserId")
		end
	end)
	
	if not Success then warn("Possible nil DataList values for UserId: ", Player.UserId, "; most likely new UserId") end
	
	---------------------------- Run Away
	return PlrSettingsF, PlrSettings
end


-- Save the data for player settings in the DataStore. Server-sided.
function Data.PlayerData.SavePlayerSettingsData(Player : Player)
	
	if not Player then warn("Failed to save player settings data, missing player argument: ", Player) return end

	---------------------------- DataStore
	local SettingsDataStore = DataStoreService:GetDataStore("SettingsDataStore")
	

	-------------------------------------- Get Data
	local PlrSettingsF = Player:FindFirstChild("settings")


	-------------------------------------- Save Data
	local DataList = {}
	
	for i, SettingInstance : ValueBase in PlrSettingsF:GetChildren() do
		if SettingInstance:IsA("ValueBase") then
			DataList[SettingInstance.Name] = SettingInstance.Value
		end
	end
	
	SettingsDataStore:SetAsync(Player.UserId, DataList)
end




---------------------------- Return

return Data
