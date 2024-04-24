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
    beamBetween.Attachment0 = pointDiscovering["Attachment"..pointDiscovering.Name] 
    beamBetween.Attachment1 = pointDiscovered["Attachment"..pointDiscovered.Name] 
    beamBetween.Parent = pointDiscovering

end

function findLeftPoint(pointPosX: number, pointPosY: number, realY: number, point: Part)

    --Checking if it's not a border

    if pointPosX == 0 then

        return

	end

    local i = (pointPosX * realY) + pointPosY

    local pointLeft = i - realY

    --Getting the point

    local leftPointInstance: any = mapGeneratedFolder["Point"..tostring(pointLeft)]
    discoverPoint(point, leftPointInstance)

end

function findTopPoint(pointPosX: number, pointPosY: number, realY: number, point: Part)
    
    if pointPosY == 0 then
        return
    end

    local i = (pointPosX * realY) + pointPosY

    local pointTop = i - 1

	local topPointInstance: any = mapGeneratedFolder["Point"..tostring(pointTop)]
    discoverPoint(point, topPointInstance)
    
end

function generateMap()

	--Clearing the current map
	mapGeneratedFolder:ClearAllChildren()
    startPointObjectValue.Value = nil
    endPointObjectValue.Value = nil

    --Getting the realX and realY X-1 to go from 0 to X

    local realX = mapGeneratorLiveConfiguration:GetAttribute("sizeX") -1
    local realY = mapGeneratorLiveConfiguration:GetAttribute("sizeY") -1

    --Creating the base pose for the point

	local pointPos: Vector3 = Vector3.new(
		0 - (realX / 2),
		0,
		0 - (realY / 2)
	)

    local pointCount = 0

	--For loop to generate
	for pointPosX: number = 0, realX, 1 do

		for pointPosY: number = 0, realY, 1 do

            --Creating the point
			local newPoint = mapPoint:Clone()
			newPoint.Parent = mapGeneratedFolder

            newPoint.Name = "Point"..tostring(pointCount)
            newPoint.BeamAttachment.Name = "AttachmentPoint"..tostring(pointCount)

            --Giving the surface gui of the point

            local surfaceGuiForPoint = surfaceGuiNumber:Clone()
            surfaceGuiForPoint.Parent = visualSurfaceGuiFolder
            surfaceGuiForPoint.Adornee = newPoint
            surfaceGuiForPoint.TextLabel.Text = tostring(pointCount)

			newPoint.Position = pointPos

            --Linking all the trigger about the status

			newPoint:GetAttributeChangedSignal("StartPoint"):Connect(function()
				changePointStatus(newPoint, "StartPoint")
			end)
            
            newPoint:GetAttributeChangedSignal("EndPoint"):Connect(function()
				changePointStatus(newPoint, "EndPoint")
			end)

            newPoint:GetAttributeChangedSignal("BlockPoint"):Connect(function()
				changePointStatus(newPoint, "BlockPoint")
			end)

            --Make the point discover top and left point around him

            findTopPoint(pointPosX, pointPosY, realY + 1, newPoint)
            findLeftPoint(pointPosX, pointPosY, realY + 1, newPoint)

            --Incrementation of point count and the position

            pointCount += 1
            pointPos += Vector3.new(0, 0, 2)

            task.wait()

		end

        --Incrementation of X and putting back Y to the default

		pointPos = Vector3.new(pointPos.X + 2, 0, 0 - (realY / 2))

	end

end


--[[
    Module
]]

local MapGeneratorModule = {}

function MapGeneratorModule.Start()
    
    --Creating the MapGeneratorControl

	mapGeneratorLiveConfiguration = Instance.new("Configuration")
	mapGeneratorLiveConfiguration.Name = "MapGeneratorControl"
	mapGeneratorLiveConfiguration.Parent = game.ServerScriptService

	--Creating the live configuration in the mapGenerator
	for attribute: string, attributeValue: any in pairs(mapGeneratorConfig) do
		mapGeneratorLiveConfiguration:SetAttribute(attribute, attributeValue)
	end

	mapGeneratorLiveConfiguration:SetAttribute("Regeneration", false)

    --Creating the start point value

	startPointObjectValue = Instance.new("ObjectValue")
	startPointObjectValue.Name = "StartPoint"
	startPointObjectValue.Parent = mapGeneratorLiveConfiguration

    startPointObjectValue:GetPropertyChangedSignal("Value"):Connect(function()  

        print("Current Start Point : "..tostring(startPointObjectValue.Value))

    end)

    --Creating the end point value

	endPointObjectValue = Instance.new("ObjectValue")
	endPointObjectValue.Name = "EndPoint"
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

    --Giving the LinkFolder the model

    local linkFolder = Instance.new("Folder")
    linkFolder.Name = "LinkFolder"
    linkFolder.Parent = mapPoint

    --Putting the SurfaceGui to have a visual number
    
	surfaceGuiNumber = Instance.new("SurfaceGui")
	surfaceGuiNumber.LightInfluence = 0
	surfaceGuiNumber.Face = Enum.NormalId.Top
    surfaceGuiNumber.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud

    --Putting the text in the surface
    
    local textInsideSurface = Instance.new("TextLabel")
    textInsideSurface.Parent = surfaceGuiNumber
    textInsideSurface.Rotation = 90

    textInsideSurface.BackgroundTransparency = 1
    textInsideSurface.Size = UDim2.new(1, 0, 1, 0)
    textInsideSurface.TextScaled = true

    --Creating the beam point for the visual

    local beamAttachment = Instance.new("Attachment")
    beamAttachment.Name = "BeamAttachment"
    beamAttachment.Parent = mapPoint

    --Creating the beam that will be clone

    beamToClone = Instance.new("Beam")
    beamToClone.FaceCamera = true

end

return MapGeneratorModule