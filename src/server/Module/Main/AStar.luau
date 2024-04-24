--[=[
	@class AStar
]=]

--[[
    Value
]]

local endFound = false

--[[
    Array
]]

local currentPointTable = {}
local pointToCheckTable = {}

--[[
    Object Value
]]

local aStarConfiguration: Configuration
local mapGeneratorLiveConfiguration: Configuration
local startPointObjectValue: any
local endPointObjectValue: any

--[[
    Function
]]

--[=[
    @within AStar

    Function who handle step by step a AStar
]=]

function aStarStep()
    warn("Step!")
	currentPointTable = table.clone(pointToCheckTable)
   	pointToCheckTable = {}

    warn(currentPointTable)
    for _, point: Part in pairs(currentPointTable) do
        warn(point)
        if not point:FindFirstChild("LinkFolder") then
            warn("No link Folder")
            continue
        end

        local linkFolder = point:FindFirstChild("LinkFolder")

        if point:GetAttribute("Checked") or point:GetAttribute("BadEnd") then
            warn("Checked or BadEnd")
            continue
        end

        point:SetAttribute("Checked", true)
        local correctLink = false

        for _, linkToCheck: ObjectValue in pairs(linkFolder:GetChildren())do

            linkToCheck:SetAttribute("CheckedLink", true)

            if not linkToCheck:IsA("ObjectValue") and not linkToCheck.Value then
                linkToCheck:SetAttribute("BadLink", true)
                continue
            end
            
            local pointToCheck: Part

            if linkToCheck.Value and linkToCheck.Value:IsA("Part") then

                pointToCheck = linkToCheck.Value

            end
    
            if pointToCheck:GetAttribute("BlockPoint") or pointToCheck:GetAttribute("Checked") then

                linkToCheck:SetAttribute("BadLink", true)
                continue

            elseif pointToCheck:GetAttribute("EndPoint") then

                endFound = true
                break 

            else

                correctLink = true
                table.insert(pointToCheckTable, pointToCheck)

            end
    
        end

        if endFound then

            point.Color = Color3.fromRGB(255, 174, 0)
            break

        elseif not correctLink then
            warn("No link")
            point:SetAttribute("BadEnd", true)
            point.Color = Color3.fromRGB(255, 0, 0)

        else
            warn("Can go further")
            point.Color = Color3.fromRGB(255, 174, 0)

        end

    end

    if endFound then

        warn("Path found")

    elseif #pointToCheckTable == 0 then

        warn("Bad End no more path")

    else
        warn("Yield until next Step")
        aStarConfiguration:GetAttributeChangedSignal("Step"):Wait()
        aStarStep()

    end

end

--[[
    Module
]]

local AStarModule = {}

--[=[
    @within AStar

    Function who start all the script to be ready to do some AStar stuff
]=]

function AStarModule.Start()
    
    aStarConfiguration = Instance.new("Configuration")
    aStarConfiguration.Name = "AStarControl"
	aStarConfiguration.Parent = game.ServerScriptService

    mapGeneratorLiveConfiguration = game.ServerScriptService.MapGeneratorControl

    startPointObjectValue = mapGeneratorLiveConfiguration:FindFirstChild("StartPoint")

	endPointObjectValue = mapGeneratorLiveConfiguration:FindFirstChild("EndPoint")

    aStarConfiguration:SetAttribute("Start", false)
    aStarConfiguration:SetAttribute("Step", false)

    aStarConfiguration:GetAttributeChangedSignal("Start"):Connect(function()

        if startPointObjectValue.Value and endPointObjectValue.Value then

            endFound = false
            table.insert(pointToCheckTable, startPointObjectValue.Value)
            aStarStep()

        else

            warn("Define Start and End, blidery idiot!")

        end
    
    end)

end

return AStarModule