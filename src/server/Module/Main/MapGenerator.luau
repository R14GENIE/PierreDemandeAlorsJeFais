--[[
    Object Value
]]

local mapGeneratorConfig = require(game.ServerScriptService.Settings.MapGeneratorSetting)

--[[
    Object Value
]]

local mapGeneratorLiveConfiguration: Configuration = game.ServerScriptService.MapGeneratorConfig
local mapGeneratedFolder: Folder = workspace.Map
local mapPoint: Part

--[[
    Function
]]

function generateMap()

    --Clearing the current map
    mapGeneratedFolder:ClearAllChildren()

    local pointPos: Vector3 = Vector3.new(0 - (mapGeneratorLiveConfiguration:GetAttribute("sizeX") / 2), 0, 0 - (mapGeneratorLiveConfiguration:GetAttribute("sizeY") / 2))

    --For loop to generate
    for pointNumberX: number = 1, mapGeneratorLiveConfiguration:GetAttribute("sizeX"), 1 do

        for pointNumberY: number = 1, mapGeneratorLiveConfiguration:GetAttribute("sizeY"), 1 do

            local newPoint = mapPoint:Clone()
            newPoint.Parent = mapGeneratedFolder

            newPoint.Position = pointPos

            pointPos += Vector3.new(0, 0, 2)

        end

        pointPos = Vector3.new(pointPos.X  + 2, 0, 0 - (mapGeneratorLiveConfiguration:GetAttribute("sizeY") / 2))

    end

end

--[[
    Module
]]

local MapGeneratorModule = {}

function MapGeneratorModule.Start()
   
    --Creating the live configuration
    for attribute: string, attributeValue: any in pairs(mapGeneratorConfig)do

        mapGeneratorLiveConfiguration:SetAttribute(attribute, attributeValue)

    end

    --Linking regen Function

    mapGeneratorLiveConfiguration:GetAttributeChangedSignal("regeneration"):Connect(generateMap)

    --Creating part model

    mapPoint = Instance.new("Part")
    mapPoint.Size = Vector3.new(1,1,1)
    mapPoint.Anchored = true
    mapPoint.CanCollide = false
    mapPoint.CanTouch = false
    mapPoint.CanQuery = false
    mapPoint:SetAttribute("StartPoint", false)
    mapPoint:SetAttribute("EndPoint", false)
    mapPoint:SetAttribute("Wall", false)

end

return MapGeneratorModule