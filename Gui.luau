-- Player Settings System
-- Made by @LunixHenry2040
-- July 2026



---------------------------- Module
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundService = game:GetService("SoundService")


---------------------------- Sounds
local MusicSounds = SoundService:WaitForChild("Music")
local MenuSoundtrack = MusicSounds.MenuSoundtrack


---------------------------- Module Scripts
local RSModuleScripts = ReplicatedStorage.ModuleScripts
local PlayersModuleScripts = RSModuleScripts.Players
local GuiModule = require(PlayersModuleScripts.GuiModule)


-- Module
local PlayerSettingsModuleScript : ModuleScript = script.Parent

local Data = require(PlayerSettingsModuleScript.Data)
local ValueRanges = Data.Constants.ValueRanges
local Bindables = Data.Bindables

local SettingsGui = {}


-- Inititalize Client Gui
function SettingsGui.InitializeClient(Player : Player, Gui : ScreenGui)
	
	--------------------------------------------------------
	---------------------------- Player 
	local Players = Players.LocalPlayer

	local Camera = workspace.CurrentCamera
	local BlurEffect = Camera:FindFirstChild("Blur") or Instance.new("BlurEffect", Camera)

	local StatusValuesF = Players:WaitForChild("StatusValues")
	
	
	local PlayerGUI = Players.PlayerGui
	local GuiStatus : Configuration = PlayerGUI:WaitForChild("GuiStatus")
	

	---------------------------- Settings Folder 
	local PlrSettingsF, PlrSettings = Data.PlayerData.GetSettingsValues(Player)
	
	
	-------------------------------------------------------- Gui
	---------------------------- Gui
	local SettingsFrame = Gui.SettingsFrame
	
	local SettingsCategoryName = SettingsFrame.SettingsCategoryName
	local Description = SettingsFrame.Description
	local SoundtrackInfoLabel = SettingsFrame.SoundtrackInfo
	

	---------------------------- Settings Categories 
	local SettingsCategorySelectionsFrame = SettingsFrame.SettingsCategorySelection
	
	local SettingsCategoryButtons = {
		Display = SettingsCategorySelectionsFrame.DisplayButton,
		Gameplay = SettingsCategorySelectionsFrame.GameplayButton,
		Sound = SettingsCategorySelectionsFrame.SoundButton,
		Other = SettingsCategorySelectionsFrame.OtherButton,
	}
	
	local SettingCategoryFrames = {
		Display = SettingsFrame.DisplayFrame,
		Gameplay = SettingsFrame.GameplayFrame,
		Sound = SettingsFrame.SoundFrame,
		Other = SettingsFrame.OtherFrame,
	}
	
	
	local SliderPercentageVs
	
	
	-------------------------------------------------------- 
	---------------------------- Status
	local Status = {
		IsSettingsOpen = false,
	}
	
	
	
	-------------------------------------------------------- Other Gui Handling
	---------------------------- Core Menu Open/Close
	
	local GuiEnabledValues = {}

	GuiService.MenuClosed:Connect(function()
		if not Status.IsSettingsOpen then return end
		task.wait()
		GuiModule.DisableSpecifiedScreenUi(Players, PlayerGUI, {"BackpackGui"})

	end)

	PlayerGUI.ChildAdded:Connect(function(GuiAdded)
		if not GuiAdded:IsA("ScreenGui") then return end

		if Status.IsSettingsOpen then
			table.insert(GuiEnabledValues, GuiModule.AddToDisableScreenUi(Players, PlayerGUI, GuiAdded))

		end

	end)

	local function checkSetGuiEffect()

		if Status.IsSettingsOpen then 

			if not StatusValuesF.IsPlayerLocked:GetAttribute("IsCameraLocked") then
				GuiModule.SetBlur(BlurEffect, Data.Constants.MenuOpenBlur, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			end

			GuiEnabledValues = GuiModule.DisableAllScreenUi(Players, PlayerGUI, {"Settings", "TopbarStandard", "TopbarStandardClipped", "TopbarCentered", "TopbarCenteredClipped"})

		elseif not GuiService.MenuIsOpen then

			if not StatusValuesF.IsPlayerLocked:GetAttribute("IsCameraLocked") then
				GuiModule.SetBlur(BlurEffect, Data.Constants.MenuCloseBlur, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			end

			GuiModule.ReEnableScreenUi(Players, PlayerGUI, GuiEnabledValues)

		end

	end
	
	

	-------------------------------------------------------- Settings Menu Gui
	---------------------------- Menu Frames
	
	-- Open/Close the Settings Menu
	local function openCloseSettingsMenu()
		Status.IsSettingsOpen = not Status.IsSettingsOpen
		SettingsFrame.Visible = Status.IsSettingsOpen
		GuiStatus:SetAttribute("IsSettingsOpen", Status.IsSettingsOpen)

		task.spawn(checkSetGuiEffect)
	end
	
	-- Close all Settings category frames
	local function closeAllSettingsCategoryFrames()
		for i, Frame : Frame in SettingCategoryFrames do
			Frame.Visible = false
		end
	end
	
	
	-- Open the specified Settings category 
	local function OpenSettingsCategory(Frame : Frame , DisplayName : string)
		closeAllSettingsCategoryFrames()
		Frame.Visible = true
		SettingsCategoryName.Text = DisplayName
		Description.Text = Data.SettingsDescs.WelcomeDesc
		GuiModule.PlayGuiSound(Players, "ButtonClick")

	end
	
	
	-- Setup Category Buttons
	for Name, Button : GuiButton in SettingsCategoryButtons do
		Button.MouseButton1Click:Connect(function()
			OpenSettingsCategory(SettingCategoryFrames[Name], Name)
		end)
	end



	-------------------------------------------------------- Settings Gui
	---------------------------- Settings Changed
	
	Bindables.VisualToggle.OnClientEvent:Connect(function(SettingInstance : ValueBase, InputUi : GuiBase)
		
		if not SettingInstance then return end
		
		local SettingFrame = if InputUi.Name == "DragButton" then InputUi.Parent.Parent else InputUi.Parent
		
		if InputUi:IsA("ImageButton") then
			InputUi.Image = 
				if SettingInstance.Value == 1 then 
					Data.Constants.ToggleOnImage
				else
					Data.Constants.ToggleOffImage

		elseif InputUi:IsA("TextBox") or SettingFrame:FindFirstChildOfClass("TextBox") then
			local ValueBox : TextBox = SettingFrame:FindFirstChildOfClass("TextBox")
			local Slider : Frame = SettingFrame:FindFirstChild("Slider")
			
			ValueBox.Text = Data.FormatSettingValue(SettingInstance)
			
			if Slider and InputUi.Name ~= "DragButton" then
				local SliderPercentageV : NumberValue = Slider:FindFirstChild("Percentage")
				local ValueRange = ValueRanges[SettingInstance.Name]
				if SliderPercentageV and ValueRange then
					SliderPercentageV.Value = math.clamp((SettingInstance.Value - ValueRange.Min) / (ValueRange.Max - ValueRange.Min), 0, 1)
				end
			end
		end
	end)
	
	
	
	---------------------------- Setup Settings Ui
	
	for SettingName, Config in Data.SettingsList do
		
		------------------------ Declarations
		local SettingInstance : ValueBase = PlrSettings[SettingName]
		
		-------- Ui
		local CategoryFrame : Frame = SettingCategoryFrames[Config.Category]
		
		
		if CategoryFrame then
			
			local SettingFrame : Frame = CategoryFrame:FindFirstChild(SettingName)
			
			if SettingFrame then
				
				---------------- Frame 
				SettingFrame.MouseEnter:Connect(function()
					Description.Text = Data.SettingsDescs[SettingName]
				end)
				
				---------------- Settings Changing
				if table.find(Config.ChangeType, "Toggle") then
					local ToggleButton : GuiButton = SettingFrame:FindFirstChild("Toggle")
					
					
					if ToggleButton and ToggleButton:IsA("GuiButton") then
						
						ToggleButton.MouseButton1Click:Connect(function()
							Bindables.SettingChanged:FireServer(SettingName, ToggleButton)
							GuiModule.PlayGuiSound(Players, "ButtonClick")
						end)
						
						ToggleButton.Image =
							if SettingInstance.Value == 1 then
								Data.Constants.ToggleOnImage
							else
								Data.Constants.ToggleOffImage
						
					end
				end
				
				
				if table.find(Config.ChangeType, "TextBox") then
					local TextBox : TextBox = SettingFrame:FindFirstChildOfClass("TextBox")

					if TextBox then
						
						TextBox.FocusLost:Connect(function(enterPressed, InputThatCausedLostFocus)
							
							-- Convert input to the correct value type
							-- Fallback to default value if input is invalid
							local InputValue = TextBox.Text

							if (not tonumber(InputValue) and Config.ValueType == "number") 
								or (typeof(InputValue) ~= Config.ValueType and Config.ValueType ~= "number") then 
								InputValue = SettingInstance.Value 
							end 

							-- Change the value
							Bindables.SettingChanged:FireServer(SettingName, TextBox, InputValue)
						end)
						
						TextBox.Text = Data.FormatSettingValue(SettingInstance)
						
					end
				end
				
				
				if table.find(Config.ChangeType, "Slider") then
					local Slider : Frame = SettingFrame:FindFirstChild("Slider")
					
					if Slider then
						local DragButton : GuiButton = Slider:FindFirstChild("DragButton")
						local PercentageV : NumberValue = Slider:FindFirstChild("Percentage")
					
						DragButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
							Bindables.SettingChanged:FireServer(SettingName, DragButton, PercentageV.Value)
						end)
						
						GuiModule.SliderUI(DragButton, Slider, "x", (SettingInstance.Value - ValueRanges[SettingName].Min) / (ValueRanges[SettingName].Max - ValueRanges[SettingName].Min))
						
					end
				end
				
				
			end
		end
	end
	
	
	
	-------------------------------------------------------- Information Ui
	---------------------------- Soundtracks

	local function checkSetSoundtrack()
		local splitStringSoundID = MenuSoundtrack.SoundId:split("//")
		local soundID = splitStringSoundID[2]
		SoundtrackInfoLabel.Text = 'Currently playing: "'..MenuSoundtrack:GetAttribute("SoundtrackName")..'", ID: '..soundID

	end

	MenuSoundtrack.Changed:Connect(checkSetSoundtrack) -- Change the soundtrack info label when the soundtrack changes
	
	
	-------------------------------------------------------- Topbar
	---------------------------- Topbar Setup
	local TopbarPlus = require(PlayersModuleScripts.SatchelLoader.Satchel.Packages.topbarplus)

	local settingsIcon = TopbarPlus.new()
		:setName("Settings")
		:setImage(Data.Constants.SettingsOpenImage, "Selected")
		:setImage(Data.Constants.SettingsCloseImage, "Deselected")
		:setImageScale(1)
		:setCaption("Settings")
		:bindToggleKey(Enum.KeyCode.P)
		:autoDeselect(false)
		:setOrder(-1)
		:align("Right")

	settingsIcon.toggled:Connect(function(): ()
		if not GuiService.MenuIsOpen then
			openCloseSettingsMenu()
		end
	end)
	
	
	
	--------------------------------------------------------
	-- Yay, you reach the end of the script!
end



return SettingsGui
