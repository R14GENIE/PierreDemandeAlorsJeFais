--[[
    Require
]]

local mapGeneratorConfig = require(game.ServerScriptService.Settings.MapGeneratorSetting)

--[[
    Value
]]

local pointColorList = {
    startPointColor = Color3.fromRGB(31, 255, 80),
    endPointColor = Color3.fromRGB(255, 31, 31),
    blockPointColor = Color3.fromRGB(31, 31, 31),
    defaultPointColor = Color3.fromRGB(163, 162, 165)
}

--[[
    Object Value
]]

local mapGeneratorLiveConfiguration: Configuration
local mapGeneratedFolder: Folder = workspace.Map
local mapPoint: Part
local startPointObjectValue: ObjectValue
local endPointObjectValue: ObjectValue

--[[
    Function
]]

function changePointStatus(point: Part, changingStat: string)
    print("Signal")
    if point:GetAttribute("changingStatus") then
        return
    end

    point:SetAttribute("changingStatus", true)

    --Reseting all other status
    if point:GetAttribute(changingStat) then

        for attributeName, attributeValue in pairs(point:GetAttributes()) do

            --Checking
            if attributeName ~= changingStat and attributeValue then

                point:SetAttribute(attributeName, false)

                if attributeName == "StartPoint" then

                    startPointObjectValue.Value = nil
    
                else
    
                    endPointObjectValue.Value = nil
    
                end            

            end

        end

    end

    --Putting the new status in place

    if changingStat == "BlockPoint" then

        if point:GetAttribute("BlockPoint") then

            point.Color = pointColorList.blockPointColor

        else

            point.Color = pointColorList.defaultPointColor

        end

    end

    if changingStat == "StartPoint" then

        if startPointObjectValue.Value and startPointObjectValue.Value:IsA("Part") then

            startPointObjectValue.Value:SetAttribute("changingStatus", true)

            startPointObjectValue.Value:SetAttribute("StartPoint", false)
            startPointObjectValue.Value.Color = pointColorList.defaultPointColor

            startPointObjectValue.Value:SetAttribute("changingStatus", false)

        end

        if point:GetAttribute("StartPoint") then

            point.Color = pointColorList.startPointColor
            startPointObjectValue.Value = point

        end
 
    end

    if changingStat == "EndPoint" then

        if endPointObjectValue.Value and endPointObjectValue.Value:IsA("Part") then

            endPointObjectValue.Value:SetAttribute("changingStatus", true)

            endPointObjectValue.Value:SetAttribute("StartPoint", false)
            endPointObjectValue.Value.Color = pointColorList.defaultPointColor

            endPointObjectValue.Value:SetAttribute("changingStatus", false)

        end

        if point:GetAttribute("EndPoint") then

            point.Color = pointColorList.endPointColor
            endPointObjectValue.Value = point

        end

    end

    point:SetAttribute("changingStatus", false)

end

function generateMap()
	--Clearing the current map
	mapGeneratedFolder:ClearAllChildren()

	local pointPos: Vector3 = Vector3.new(
		0 - (mapGeneratorLiveConfiguration:GetAttribute("sizeX") / 2),
		0,
		0 - (mapGeneratorLiveConfiguration:GetAttribute("sizeY") / 2)
	)

    local pointCount = 1

	--For loop to generate
	for pointNumberX: number = 1, mapGeneratorLiveConfiguration:GetAttribute("sizeX"), 1 do
		for pointNumberY: number = 1, mapGeneratorLiveConfiguration:GetAttribute("sizeY"), 1 do
			local newPoint = mapPoint:Clone()
			newPoint.Parent = mapGeneratedFolder

			newPoint.Position = pointPos

			pointPos += Vector3.new(0, 0, 2)

			newPoint:GetAttributeChangedSignal("StartPoint"):Connect(function()
				changePointStatus(newPoint, "StartPoint")
			end)
            
            newPoint:GetAttributeChangedSignal("EndPoint"):Connect(function()
				changePointStatus(newPoint, "EndPoint")
			end)

            newPoint:GetAttributeChangedSignal("BlockPoint"):Connect(function()
				changePointStatus(newPoint, "BlockPoint")
			end)

            newPoint.Name = "Point"..tostring(pointCount)

            pointCount += 1

            task.wait()

		end

		pointPos = Vector3.new(pointPos.X + 2, 0, 0 - (mapGeneratorLiveConfiguration:GetAttribute("sizeY") / 2))
	end
end

--[[
    Module
]]

local MapGeneratorModule = {}

function MapGeneratorModule.Start()
	mapGeneratorLiveConfiguration = Instance.new("Configuration")
	mapGeneratorLiveConfiguration.Name = "MapGeneratorControl"
	mapGeneratorLiveConfiguration.Parent = game.ServerScriptService
	--Creating the live configuration
	for attribute: string, attributeValue: any in pairs(mapGeneratorConfig) do
		mapGeneratorLiveConfiguration:SetAttribute(attribute, attributeValue)
	end

	mapGeneratorLiveConfiguration:SetAttribute("Regeneration", false)

	startPointObjectValue = Instance.new("ObjectValue")
	startPointObjectValue.Name = "StartPoint"
	startPointObjectValue.Parent = mapGeneratorLiveConfiguration

    startPointObjectValue:GetPropertyChangedSignal("Value"):Connect(function()  

        print(startPointObjectValue.Value)

    end)

	endPointObjectValue = Instance.new("ObjectValue")
	endPointObjectValue.Name = "EndPont"
	endPointObjectValue.Parent = mapGeneratorLiveConfiguration

    endPointObjectValue:GetPropertyChangedSignal("Value"):Connect(function()
    
        print(endPointObjectValue.Value)

    end)

	--Linking regen Function

	mapGeneratorLiveConfiguration:GetAttributeChangedSignal("Regeneration"):Connect(generateMap)

	--Creating part model

	mapPoint = Instance.new("Part")
	mapPoint.Size = Vector3.new(1, 1, 1)
	mapPoint.Anchored = true
	mapPoint.CanCollide = false
	mapPoint.CanTouch = false
	mapPoint.CanQuery = true
	mapPoint:SetAttribute("StartPoint", false)
	mapPoint:SetAttribute("EndPoint", false)
	mapPoint:SetAttribute("BlockPoint", false)
    mapPoint:SetAttribute("changingStatus", false)

end

return MapGeneratorModule
