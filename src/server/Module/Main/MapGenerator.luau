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
local visualSurfaceGuiFolder: Folder = workspace.VisualSurfaceGui
local mapPoint: Part
local startPointObjectValue: ObjectValue
local endPointObjectValue: ObjectValue
local surfaceGuiNumber: SurfaceGui
local beamToClone: Beam

--[[
    Function
]]

function changePointStatus(point: Part, changingStat: string)

    if point:GetAttribute("changingStatus") then
        return
    end

    point:SetAttribute("changingStatus", true)

    if changingStat == "StartPoint" then

        if point:GetAttribute("StartPoint") then

            point.Color = pointColorList.startPointColor

            point:SetAttribute("BlockPoint", false)
            
            if point:GetAttribute("EndPoint") then

                endPointObjectValue.Value = nil
                point:SetAttribute("EndPoint", false)

            end

            if startPointObjectValue.Value and startPointObjectValue.Value:IsA("Part") then

                startPointObjectValue.Value:SetAttribute("changingStatus", true)
                
                startPointObjectValue.Value:SetAttribute("StartPoint", false)
                startPointObjectValue.Value.Color = pointColorList.defaultPointColor

                startPointObjectValue.Value:SetAttribute("changingStatus", false)
                task.wait()
            end

            startPointObjectValue.Value = point

        else

            point.Color = pointColorList.defaultPointColor
            startPointObjectValue.Value = nil

        end

    end

    if changingStat == "EndPoint" then

        if point:GetAttribute("EndPoint") then

            point.Color = pointColorList.endPointColor

            point:SetAttribute("BlockPoint", false)
            
            if point:GetAttribute("StartPoint") then

                startPointObjectValue.Value = nil
                point:SetAttribute("StartPoint", false)

            end

            if endPointObjectValue.Value and endPointObjectValue.Value:IsA("Part") then

                endPointObjectValue.Value:SetAttribute("changingStatus", true)
                
                endPointObjectValue.Value:SetAttribute("EndPoint", false)
                endPointObjectValue.Value.Color = pointColorList.defaultPointColor

                endPointObjectValue.Value:SetAttribute("changingStatus", false)
                task.wait()
            end

            endPointObjectValue.Value = point

        else

            point.Color = pointColorList.defaultPointColor
            endPointObjectValue.Value = nil

        end

    end

    if changingStat == "BlockPoint" then

        if point:GetAttribute("BlockPoint") then

            point.Color = pointColorList.blockPointColor
            
            if point:GetAttribute("StartPoint") then

                startPointObjectValue.Value = nil
                point:SetAttribute("StartPoint", false)

            end

            if point:GetAttribute("EndPoint") then

                endPointObjectValue.Value = nil
                point:SetAttribute("EndPoint", false)

            end

        else

            point.Color = pointColorList.defaultPointColor

        end

    end

    point:SetAttribute("changingStatus", false)

end

function discoverPoint(pointDiscovering: any, pointDiscovered: any)

    local discoveredObjectValue = Instance.new("ObjectValue")
    discoveredObjectValue.Parent = pointDiscovered.LinkFolder
    discoveredObjectValue.Value = pointDiscovering

    local discoveringObjectValue = Instance.new("ObjectValue")
    discoveringObjectValue.Parent = pointDiscovering.LinkFolder
    discoveringObjectValue.Value = pointDiscovered

    local beamBetween = beamToClone:Clone()
    beamBetween.Attachment0 = pointDiscovering.BeamAttachment 
    beamBetween.Attachment1 = pointDiscovered.BeamAttachment
    beamBetween.Parent = visualSurfaceGuiFolder

end

function findLeftPoint(pointPosX: number, pointPosY: number, realX: number, point: Part)

    if pointPosX == 0 then

        return

	end
	
	realX += 1

    local topPoint: any = mapGeneratedFolder["Point"..tostring((realX * (pointPosX-1)) + pointPosY )]
    discoverPoint(point, topPoint)

end

function findTopPoint(pointPosX: number, pointPosY: number, realX: number, point: Part)
    
    if pointPosY == 0 then
        return
    end

    realX += 1

    local leftPoint: any = mapGeneratedFolder["Point"..tostring((realX * (pointPosX)) + (pointPosY - 1) )]
    discoverPoint(point, leftPoint)
    
end

function generateMap()
	--Clearing the current map
	mapGeneratedFolder:ClearAllChildren()
    startPointObjectValue.Value = nil
    endPointObjectValue.Value = nil

    local realX = mapGeneratorLiveConfiguration:GetAttribute("sizeX") -1
    local realY = mapGeneratorLiveConfiguration:GetAttribute("sizeY") -1

	local pointPos: Vector3 = Vector3.new(
		0 - (realX / 2),
		0,
		0 - (realY / 2)
	)

    local pointCount = 0

	--For loop to generate
	for pointPosX: number = 0, realX, 1 do

		for pointPosY: number = 0, realY, 1 do

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

            local surfaceGuiForPoint = surfaceGuiNumber:Clone()
            surfaceGuiForPoint.Parent = visualSurfaceGuiFolder
            surfaceGuiForPoint.Adornee = newPoint
            surfaceGuiForPoint.TextLabel.Text = tostring(pointCount)

            findTopPoint(pointPosX, pointPosY, realX, newPoint)
            findLeftPoint(pointPosX, pointPosY, realX, newPoint)

            pointCount += 1

            task.wait()

		end

		pointPos = Vector3.new(pointPos.X + 2, 0, 0 - (realY / 2))

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

        print("Current Start Point : "..tostring(startPointObjectValue.Value))

    end)

	endPointObjectValue = Instance.new("ObjectValue")
	endPointObjectValue.Name = "EndPont"
	endPointObjectValue.Parent = mapGeneratorLiveConfiguration

    endPointObjectValue:GetPropertyChangedSignal("Value"):Connect(function()
    
        print("Current End Point : "..tostring(endPointObjectValue.Value))

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

    local linkFolder = Instance.new("Folder")
    linkFolder.Name = "LinkFolder"
    linkFolder.Parent = mapPoint
    
	surfaceGuiNumber = Instance.new("SurfaceGui")
	surfaceGuiNumber.LightInfluence = 0
	surfaceGuiNumber.Face = Enum.NormalId.Top
    surfaceGuiNumber.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    
    local textInsideSurface = Instance.new("TextLabel")
    textInsideSurface.Parent = surfaceGuiNumber
    textInsideSurface.Rotation = 90

    textInsideSurface.BackgroundTransparency = 1
    textInsideSurface.Size = UDim2.new(1, 0, 1, 0)
    textInsideSurface.TextScaled = true

    local beamAttachment = Instance.new("Attachment")
    beamAttachment.Name = "BeamAttachment"
    beamAttachment.Parent = mapPoint

    beamToClone = Instance.new("Beam")
    beamToClone.FaceCamera = true

end

return MapGeneratorModule