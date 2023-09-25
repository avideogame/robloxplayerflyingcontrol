-- game.ServerScriptService.MyGameModuleScript
local aModule = {}

aModule.MyConfig = {}
-- Data Definition
aModule.MyConfig["MyLanguage"] = {
	MyType = {
		MyEnglish = {
			aKey = "aEnglish",
		},
		MyChinese = {
			aKey = "aChinese",
		},
	},
}
aModule.MyConfig["MyGame"] = {
	aScreenOrientation = Enum.ScreenOrientation.LandscapeSensor,
	aLanguageDefault = aModule.MyConfig.MyLanguage.MyType.MyEnglish.aKey,

	MyExperience = {
		aId = 1234567890,
	},
	MyPlace  = {
		aId = 12345678901,
		MyLabel = {
			aEnglish = "Roblox Player Flying Control",
			aChinese = "Roblox Player Flying Control",
		},
		MyTemplate = {
			aType = "Baseplate",
		},
	},

	MyBadge = {
		aName = "MyBadge",
		MyKeyMaster = {
			aId = "1234567890",
		},
	},
}

aModule.MyConfig["MyRemoteEvent"] = {
	MyServerClientTrigger = {
	},
	MyClientServerTrigger = {
		MySetPlayerDirection = {
			aName = "MyRemoteEventClientServerSetPlayerDirection",
		},
		MySetPlayerFlyFlag = {
			aName = "MyRemoteEventClientServerSetPlayerFlyFlag",
		},
	},
}

aModule.MyConfig["MyPlayer"] = {
	MyAttribute = {
		MyLanguage = {
			aName = "MyLanguage",
			aKey = "aLanguage",
			MyValue = {
				aDefault = ""..aModule.MyConfig.MyGame.aLanguageDefault
			},
		},
		MyFlag = {
			MyFly = {
				aName = "MyFly",
				aKey = "aFly",
			},
		},
	},

	MyFly = {
		aName = "MyFly",
		MyOffset = {
			aY = 100,
		},
		MyDirection = {
			aUp = "u",
			aDown = "d",
			aLeft = "l",
			aRight = "r",
		},
		MyScreenFly = {
			aName = "MyScreenFly",
			MyButtonFly = {
				aName = "MyButtonFly",
				MySize = {
					aX = 50,
					aY = 50,
				},
			},
		},
		MyMove = {
			aRate = 4,
		},
	},

}
aModule.MyConfig["MyDataStore"] = {
	MyField = {
		MyPlayerLanguage = {
			aName = "MyPlayerLanguage",
		},
	},
}

-- Objects

aModule.MyGame = {}
-- Cache space
aModule.MyGame.MyState = {
	aTimestamp = nil,
}
aModule.MyGame.SetInit = function(aParam)
	local aConfig = aModule.MyConfig

	aModule.MyGame.SetSettingsInit(aParam)
	aModule.MyGame.SetPlayersInit(aParam)

	return
end

aModule.MyGame.SetFrameUpdate = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aInstance
	local aName
	local aPlayer

	if aModule.MyGame.MyState.aTimestamp == nil then
		aModule.MyGame.MyState.aTimestamp = os.time()
	end

	if aModule.MyGame.MyState.aTimestamp < os.time() then
		aModule.MyGame.MyState.aTimestamp = os.time()

		aService = game:GetService("Players")
		local playerList = aService:GetPlayers()
		for i = 1, #playerList  do
			local player = playerList[i]
			if player:GetAttribute("IsAlive") then
				local points = player.leaderstats.Points
				points.Value = points.Value + 1
			end
		end

	end
	aModule.MyGame.MyFly.SetHandle(aParam)

	return
end

aModule.MyGame.SetOnPlayerAdded = function(aPlayer)
	local aConfig = aModule.MyConfig

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = aPlayer

	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Value = 0
	points.Parent = leaderstats

	aPlayer:SetAttribute("IsAlive", false)

	aPlayer.CharacterAdded:Connect(function(aCharacter)
		aModule.MyGame.SetOnCharacterAdded({character=aCharacter,player=aPlayer,})
	end)

	return
end

aModule.MyGame.SetOnCharacterAdded = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer = aParam.player
	local aCharacter = aParam.character
	aPlayer:SetAttribute("IsAlive", true)
	local humanoid = aCharacter:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		local points = aPlayer.leaderstats.Points
		points.Value = 0
		aPlayer:SetAttribute("IsAlive", false)
	end)

	return
end

aModule.MyGame.SetPlayersInit = function(aParam)
	local aService
	aService = game:GetService("Players")
	aService.PlayerAdded:Connect(aModule.MyGame.SetOnPlayerAdded)
	aService.PlayerAdded:Connect(aModule.MyGame.SetPlayerAddedInit)

end

aModule.MyGame.SetSettingsInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aScript
	local aInstance

	aService = game:GetService("StarterGui")
	aService.ScreenOrientation = aConfig.MyGame.aScreenOrientation

	aService = game:GetService("Lighting")
	aService.Brightness = 1

	-- Stage to script on ReplicatedStorage to share between player space and game space
	aScript = game:GetService("ServerScriptService"):WaitForChild("MyGameModuleScript"):Clone()
	aScript.Parent = game:GetService("ReplicatedStorage")

	aModule.MyGame.SetRemoteEventInit(aParam)

	return
end

aModule.MyGame.SetPlayerAddedInit = function(aPlayer)
	local aService
	local aConfig = aModule.MyConfig
	local aName
	local aInstance

	aModule.MyGame.SetPlayerLanguageInit({["aPlayer"] = aPlayer,})

	--	aModule.MyGame.SetPlayerBadgeInit({["aPlayer"] = aPlayer,})

	aPlayer.CharacterAdded:Connect(function(aCharacter)
		task.wait()
		aName = "Points"
		local aPoints
		aPoints = aPlayer.leaderstats:FindFirstChild(aName)
		if aPoints == nil then
			aPoints = Instance.new("IntValue")
			aPoints.Name = ""..aName
			aPoints.Parent = aPlayer.leaderstats
		end
		aPoints.Value = 0

	end)

	aPlayer.CharacterAdded:Connect(function(aCharacter)
		task.wait()
		aName = aConfig.MyPlayer.MyAttribute.MyFlag.MyFly.aKey
		local aFlag
		aFlag = aPlayer.leaderstats:FindFirstChild(aName)
		if aFlag == nil then
			aFlag = Instance.new("IntValue")
			aFlag.Name = ""..aName
			aFlag.Parent = aPlayer.leaderstats
		end
		aFlag.Value = 0
	end)
end

aModule.MyGame.SetRemoteEventInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aInstance
	local aFunc
	
	aInstance = Instance.new("RemoteEvent")
	aInstance.Name = aConfig.MyRemoteEvent.MyClientServerTrigger.MySetPlayerFlyFlag.aName
	aInstance.Parent = game:GetService("ReplicatedStorage")
	aInstance.OnServerEvent:Connect(function(aPlayer2, aParam2)
		local aInstance2
		local aPosition2
		local aParent2
		local aPart
		local aHumanoid2
		local aName2
		local aLanguage2
		aName2 = aConfig.MyPlayer.MyAttribute.MyFlag.MyFly.aKey
		for _,aValue2 in ipairs(game:GetService("Players"):GetChildren()) do
			if aValue2.UserId == aPlayer2.UserId then
				if aValue2.leaderstats == nil then
					break
				end
				if aValue2.leaderstats:FindFirstChild(aName2) == nil then
					aLanguage2 = aModule.MyPlayer.MyLanguage.GetType({["aPlayer"]=aValue2,})
					aLanguage2 = aConfig.MyLanguage.MyType[""..aLanguage2].aKey
					break
				end
				local aTemp
				aTemp = aValue2.leaderstats[""..aName2].Value
				aTemp += 1
				aTemp %= 2
				aValue2.leaderstats[""..aName2].Value = aTemp
				break
			end

		end

	end)

	aFunc = function(aPlayer2, aParam2)
		local aInstance2
		local aPosition2
		local aParent2
		local aPart
		local aHumanoid2
		local aName2
		local aCharacter2
		local aOffset2
		local aCFrame2

		for _,aValue2 in ipairs(game:GetService("Players"):GetChildren()) do
			if aValue2.UserId ~= aPlayer2.UserId then
				continue
			end
			aName2 = aPlayer2.leaderstats:FindFirstChild(""..aConfig.MyPlayer.MyAttribute.MyFlag.MyFly.aKey)
			if aName2 == nil then
				break
			end
			if aName2.Value ~= 1 then
				break
			end

			local aRate = 10
			aRate = aConfig.MyPlayer.MyFly.MyMove.aRate
			aCharacter2 = aPlayer2.Character or aPlayer2.CharacterAdded:Wait()
			aCFrame2 = aParam2.aLookVector
			aCFrame2 += aParam2.aLookVector.LookVector * aRate
			aCharacter2.HumanoidRootPart.CFrame = aCFrame2
			break
		end

	end
	aInstance = Instance.new("RemoteEvent")
	aInstance.Name = aConfig.MyRemoteEvent.MyClientServerTrigger.MySetPlayerDirection.aName
	aInstance.Parent = game:GetService("ReplicatedStorage")
	aInstance.OnServerEvent:Connect(aFunc)

end

aModule.MyGame.SetPlayerLanguage = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aInstance
	local aName
	local aPlayer
	local aKey

	aPlayer = aParam["aPlayer"]
	aKey = aParam["aKey"]

	aName = aModule.MyConfig.MyDataStore.MyField.MyPlayerLanguage.aName
	aService = game:GetService("DataStoreService")
	aInstance = aService:GetDataStore(""..aName)

	if aInstance:GetAsync(aPlayer.UserId) == nil then
		aInstance:SetAsync(aPlayer.UserId, ""..aModule.MyConfig.MyPlayer.MyAttribute.MyLanguage.MyValue.aDefault)
	end

	for k,v in pairs(aConfig.MyLanguage.MyType) do
		if aKey == nil then
			break
		end
		if v.aKey ~= aKey then
			continue
		end

		-- Set data store key

		local setSuccess, errorMessage = pcall(function()

			aInstance:SetAsync(aPlayer.UserId, ""..aKey)

		end)

		if not setSuccess then

			warn(errorMessage)

		end
		break
	end

	-- Read data store key

	local getSuccess, currentLanguage = pcall(function()

		return aInstance:GetAsync(aPlayer.UserId)

	end)

	if getSuccess then

		--		print(currentLanguage)

		aName = aConfig.MyPlayer.MyAttribute.MyLanguage.aKey
		aPlayer:SetAttribute(""..aName, currentLanguage)
	end
end

aModule.MyGame.SetPlayerLanguageInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aList
	local aInstance
	local aName
	local aPlayer = aParam["aPlayer"]
	local aLanguage

	aService = game:GetService("Players")

	aList = aService:GetPlayers()
	for i = 1, #aList  do
		aInstance = aList[i]
		if aPlayer.UserId ~= aInstance.UserId then
			continue
		end

		aLanguage = ""..aConfig.MyPlayer.MyAttribute.MyLanguage.MyValue.aDefault 
		aService = game:GetService("DataStoreService")
		aName = aConfig.MyDataStore.MyField.MyPlayerLanguage.aName
		aInstance = aService:GetDataStore(""..aName)
		--		aInstance:RemoveAsync(aPlayer.UserId)
		local getSuccess, currentLanguage = pcall(function()
			return aInstance:GetAsync(aPlayer.UserId)
		end)

		if getSuccess then
			if  currentLanguage == nil then
			else
				aLanguage = ""..currentLanguage
			end
		else
		end

		aName = ""..aConfig.MyPlayer.MyAttribute.MyLanguage.aKey
		aPlayer:SetAttribute(""..aName, ""..aLanguage)
		aInstance:SetAsync(aPlayer.UserId, aPlayer:GetAttribute(""..aName))

		break
	end
end

aModule.MyGame.SetPlayerBadgeInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer = aParam["aPlayer"]
	local aService
	local aInstance
	local aName
	local aParent

	--
	local BadgeService = game:GetService("BadgeService")

	local function awardBadge(player, badgeId)
		-- Fetch Badge information
		local success, badgeInfo = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeId)
		if success then
			-- Confirm that badge can be awarded
			if badgeInfo.IsEnabled then
				-- Award badge
				local awarded, errorMessage = pcall(BadgeService.AwardBadge, BadgeService, player.UserId, badgeId)
				if not awarded then
					warn("Error while awarding Badge:", errorMessage)
				end
			end
		else
			warn("Error while fetching Badge info!")
		end
	end
	--
	if "0" ~= "" then
		local BadgeService = game:GetService("BadgeService")
		local Players = game:GetService("Players")

		local BADGE_ID = 00000000  -- Change this to your Badge ID

		--
		BADGE_ID = aConfig.MyGame.MyBadge.MyKeyMaster.aId

		local function onPlayerAdded(player)
			--
			local badgeID = BADGE_ID

			-- Check if the player has the Badge
			local success, hasBadge = pcall(BadgeService.UserHasBadgeAsync, BadgeService, player.UserId, badgeID)

			-- If there's an error, issue a warning and exit the function
			if not success then
				warn("Error while checking if player has Badge!")
				return
			end

			if hasBadge then
				-- Handle player's Badge ownership as needed
				--
				local BadgeService = game:GetService("BadgeService")

				local BADGE_ID = 00000000  -- Change this to your Badge ID
				--
				BADGE_ID = aConfig.MyGame.MyBadge.MyKeyMaster.aId

				-- Fetch Badge information
				local success, result = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, BADGE_ID)
				--								print(success, result)

				-- Output the information
				if success then
					if "0" == "" then
						print("Badge:", result.Name)
						print("Enabled:", result.IsEnabled)
						print("Description:", result.Description)
						print("Icon:", "rbxassetid://" .. result.IconImageId)
					end
				else
					warn("Error while fetching Badge info:", result)
				end
				--
			end

			if hasBadge ~= true then
				awardBadge(player, BADGE_ID)
				--				BadgeService:AwardBadge(player.UserId, badgeID)
			end
		end

		-- Connect "PlayerAdded" events to the "onPlayerAdded()" function
		--		Players.PlayerAdded:Connect(onPlayerAdded)
		onPlayerAdded(aPlayer)
	end
	--
end

aModule.MyGame.MyFly = {}
aModule.MyGame.MyFly.SetHandle = function(aParam)
	local aConfig = aModule.MyConfig
	local aName
	local aInstance
	local aService
	local aParent
	local aPosition
	local aBaseplate
	local aTemp

	aService = game:GetService("Workspace")
	aInstance = aService:FindFirstChild("Baseplate")
	if aInstance == nil then
		return		
	end
	aBaseplate = aInstance

	aService = game:GetService("Players")
	local playerList = aService:GetPlayers()
	for i = 1, table.maxn(playerList)  do
		local aPlayer = playerList[i]
		local aCharacter = aPlayer.Character or aPlayer.CharacterAdded:Wait()

		aInstance = aCharacter:FindFirstChild("HumanoidRootPart")
		if aInstance == nil then
			continue
		end
		
		aInstance = aPlayer.leaderstats
		if aInstance == nil then
			continue
		end
		aTemp = aInstance:FindFirstChild(""..aConfig.MyPlayer.MyAttribute.MyFlag.MyFly.aKey)
		if aTemp ~= nil then
			if aTemp.Value == 1 then
				aCharacter.HumanoidRootPart.Anchored = true
				aPosition = aCharacter.HumanoidRootPart.Position
				aPosition = Vector3.new(aPosition.x, aBaseplate.Position.y+aConfig.MyPlayer.MyFly.MyOffset.aY, aPosition.z)
				aCharacter.HumanoidRootPart.Position = aPosition
			else
				aCharacter.HumanoidRootPart.Anchored = false
			end
		end
	end
end

aModule.MyGame.GetVector2Input = function(aParam)
	local aMovementVector = aParam["aMovementVector"]
	local aCameraLook =aParam["aCameraLook"] 
	local aOffset
	local aInputDirection
	
	aOffset = CFrame.lookAt(Vector3.zero, Vector3.new(0,0,aCameraLook.z)) * aMovementVector
	aInputDirection = Vector2.new(aOffset.X, aOffset.Z)

	if aInputDirection ~= Vector2.zero then
		return aInputDirection.Unit
	end

	return aInputDirection
end

-- Player space perspective
aModule.MyPlayer = {}

aModule.MyPlayer.SetLocalInit = function(aParam)
	aModule.MyPlayer.MyRemoteEvent.SetInit(aParam)

	aModule.MyPlayer.SetPlayerAddedInit(aParam)
end

aModule.MyPlayer.SetLocalUpdate = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aLanguage
	local aPlayer

	aService = game:GetService("Players")
	aPlayer = aService.LocalPlayer
	aLanguage = aModule.MyPlayer.MyLanguage.GetType({["aPlayer"]=aPlayer,})

end

aModule.MyPlayer.MyLanguage = {}
aModule.MyPlayer.MyLanguage.GetType = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer = aParam["aPlayer"]
	local aService
	local aKey
	local aList
	local aType

	aService = game:GetService("Players")
	aKey = aConfig.MyPlayer.MyAttribute.MyLanguage.MyValue.aDefault
	aList = aService:GetPlayers()
	for i,aValue in ipairs(aList) do
		if aValue.UserId ~= aPlayer.UserId then
			continue
		end
		for k,v in pairs(aConfig.MyLanguage) do
			for aFieldKey, aFieldValue in pairs(v) do
				if aFieldValue.aKey == aValue:GetAttribute(aConfig.MyPlayer.MyAttribute.MyLanguage.aKey) then
					aKey = aFieldKey
					return aKey
				end
			end

		end
	end

	return aKey
end

aModule.MyPlayer.MyRemoteEvent = {}
aModule.MyPlayer.MyRemoteEvent.SetInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aInstance
	local aName
	local aPlayer
	local aLanguage

	aService = game:GetService("Players")
	aPlayer = aService.LocalPlayer
	aLanguage = aModule.MyPlayer.MyLanguage.GetType({["aPlayer"]=aPlayer,})

end

aModule.MyPlayer.SetPlayerAddedInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aService
	local aPlayer
	local aName
	local aInstance
	local aCharacter
	local aParent
	aPlayer = aParam["player"]
	--	aCharacter = aPlayer.Character or aPlayer.CharacterAdded:Wait()

	aPlayer.CharacterAdded:Connect(function(aCharacter2)

		coroutine.wrap(function(aParam)
			--			task.wait()
			local aHumanoid = aParam["aCharacter"]:WaitForChild("Humanoid")

			aHumanoid.Touched:Connect(function(aOtherPart)
				local aHitPlayer
				aHitPlayer = game.Players:GetPlayerFromCharacter(aOtherPart.Parent)
				if string.match(aOtherPart.Name,"^(.*)Foot") == nil then
					--					return
				end
			end)			
		end)({["aCharacter"]=aCharacter2,["aPlayer"]=aPlayer,})
		
		aModule.MyPlayer.MyFly.SetInit(aParam)
	end)

	return
end

aModule.MyPlayer.MyFly = {}
aModule.MyPlayer.MyFly.SetInit = function(aParam)
	local aConfig = aModule.MyConfig
	local aPlayer
	local aService
	local aInstance
	local aParent
	local aName
	local aOffset

	aService = game:GetService("Players")
	aPlayer = aService.LocalPlayer
	aPlayer = aService:GetPlayerByUserId(aPlayer.UserId)

	coroutine.wrap(function(aParam2)
		local aController = require(aPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
		local aCurrentCamera = game:GetService("Workspace").CurrentCamera
		local aMovementVector
		local aAngle
		local aInputVector
		
		while wait() do
			aMovementVector = aController:GetMoveVector()
			if aMovementVector == Vector3.zero then
				task.wait()
				continue
			end

			aInputVector = aModule.MyGame.GetVector2Input({
				["aMovementVector"]=aMovementVector,
				["aCameraLook"]=aCurrentCamera.CFrame.LookVector,
			})

			if aInputVector == Vector2.zero then
				task.wait()
				continue
			end
			aInputVector = aInputVector * -1

			aAngle = math.deg(math.atan2(aInputVector.X, aInputVector.Y))

			for _,aValue in ipairs(game:GetService("Workspace"):GetChildren()) do
				if aValue.ClassName ~= "Model" then
					continue
				end

				aInstance = game:GetService("Players"):GetPlayerFromCharacter(aValue)
				if aInstance == nil then
					continue
				end

				if aInstance.UserId ~= aPlayer.UserId then
					continue
				end

				aInstance = aValue:FindFirstChild("HumanoidRootPart")
				if aInstance == nil then
					continue
				end

				local aCFrame1
				local aCFrame2
				local aCFrame3

				aCFrame1 = aValue.HumanoidRootPart.CFrame
				aCFrame2 = aCurrentCamera.CFrame
				aOffset = Vector3.new(aCFrame2.Position.X,aCFrame1.Position.Y,aCFrame2.Position.Z)
				aCFrame3 = CFrame.lookAt(aCFrame1.Position, aOffset)
				if math.deg(aCFrame2.LookVector.Z) < 0 then
					aCFrame3 = aCFrame3 * CFrame.Angles(0,math.rad(180.0),0)
				end
				aCFrame3 = aCFrame3 * CFrame.Angles(0,math.rad(aAngle),0)

				aValue.HumanoidRootPart.CFrame = aCFrame3

				if "0" ~= "" then
					local aName2
					aName2 = aConfig.MyRemoteEvent.MyClientServerTrigger.MySetPlayerDirection.aName
					game:GetService("ReplicatedStorage"):WaitForChild(""..aName2):FireServer({
						["aKey"]=""..aPlayer.UserId,
						["aLookVector"]=aValue.HumanoidRootPart.CFrame,
					})
				end

				break
			end
		end
	end)({})
	

	aParent = aPlayer:FindFirstChild("PlayerGui")
	aName = aConfig.MyPlayer.MyFly.MyScreenFly.aName
	aInstance = aParent:FindFirstChild(""..aName)
	if aInstance ~= nil then
		--		aInstance:Destroy()
		--		aInstance = nil
		return
	end

	aInstance = Instance.new("ScreenGui")
	aInstance.Name = ""..aName
	aInstance.Parent = aParent
	aParent = aInstance

	aOffset = aConfig.MyPlayer.MyFly.MyScreenFly.MyButtonFly.MySize.aX

	aInstance = Instance.new("TextButton")
	aInstance.Parent = aParent
	aInstance.Text = " OFF / ON "
	aInstance.Position = UDim2.new(0.75,0.25,0.75,0.25)
	aInstance.Size = UDim2.new(0,aOffset,0,aOffset)

	aInstance.MouseButton1Down:Connect(function()
		aService = game:GetService("ReplicatedStorage") 
		aName = aConfig.MyRemoteEvent.MyClientServerTrigger.MySetPlayerFlyFlag.aName
		aService:WaitForChild(""..aName):FireServer({["aKey"]=""..aPlayer.UserId,})
	end)

end

return aModule
