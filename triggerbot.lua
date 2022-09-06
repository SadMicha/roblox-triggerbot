local local_player = game:GetService("Players").LocalPlayer
local mouse = local_player:GetMouse()
local uis = game:GetService("UserInputService")
local run_service = game:GetService("RunService")
local getgenv = getgenv
local string_char = string.char
local math_random = math.random
local math_randomseed = math.randomseed
local raycast = workspace.Raycast
local instance_new = Instance.new
local dummy_part = instance_new("Part", nil)

-- randomizer

math_randomseed(tick())
function random_string(len)
	local str = ""
	for i = 1, len do
		str = str .. string_char(math_random(97, 122))
	end
	return str
end

getgenv().toggle_key = Enum.KeyCode["E"]
getgenv().update_loop_stepped_name = random_string(math_random(15, 35))

-- functions I need

local ignored_instances = {}
local function wall_check(target)
    local raycast_params = RaycastParams.new()
    raycast_params.FilterType = Enum.RaycastFilterType.Blacklist
    raycast_params.IgnoreWater = true

    local ignore_list = {workspace.CurrentCamera, local_player.Character}

    for _, val in pairs(ignored_instances) do
        ignore_list[#ignore_list + 1] = val
    end

    local raycast_result = raycast(workspace, local_player.Character.Head.Position, (target.Character.PrimaryPart.Position - local_player.Character.PrimaryPart.Position).Unit * 1000, raycast_params)
    local result_part = ((raycast_result and raycast_result.Instance) or dummy_part)

    raycast_params.FilterDescendantsInstances = ignore_list

    if result_part ~= dummy_part then
        if result_part.Transparency >= 0.3 then -- ignore low transparency
            ignored_instances[#ignored_instances + 1] = result_part
        end

        if result_part.Material == Enum.Material.Glass then -- ignore glass
            ignored_instances[#ignored_instances + 1] = result_part
        end
    end
    
    return game.IsDescendantOf(result_part, target.Character)
end

local function check_same_team(target)
    local placeId = game.PlaceId

    if placeId == 5361853069 then -- Snow Core
        local leaderboard = local_player:FindFirstChild("PlayerGui"):FindFirstChild("LeaderboardUI")
        local leaderboardNew = leaderboard:FindFirstChild("LeaderboardNew")
        local teamA = leaderboardNew:FindFirstChild("TeamAFrame"):FindFirstChild("TeamA"):FindFirstChild("PlayersList")
        local teamB = leaderboardNew:FindFirstChild("TeamBFrame"):FindFirstChild("TeamB"):FindFirstChild("PlayersList")

        local playerTeams = {}

        for _, items in ipairs(teamA:GetChildren()) do
            if items.Name == target.Name then
                playerTeams[#playerTeams + 1] = target.Name
            elseif items.Name == local_player.Name then
                playerTeams[#playerTeams + 1] = local_player.Name
            end
        end

        if #playerTeams >= 2 then
            return true
        else
            playerTeams = {}
            for _, items in ipairs(teamB:GetChildren()) do
                if items.Name == target.Name then
                    playerTeams[#playerTeams + 1] = target.Name
                elseif items.Name == local_player.Name then
                    playerTeams[#playerTeams + 1] = local_player.Name
                end
            end

            if #playerTeams >= 2 then
                return true
            end
        end
    else
        if target.TeamColor == local_player.TeamColor then
            return true
        end
    end
    
    return false
end

-- uis

local toggled = false
uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == getgenv().toggle_key then
            toggled = not toggled
        end
    end
end)

-- render step

local last_tick = 0
local function stepped()
    if (tick() - last_tick) > (10 / 1000) then
        last_tick = tick()
        if toggled then
            if mouse.Target and mouse.Target.Parent then
                if mouse.Target:FindFirstChild("Humanoid") or mouse.Target.Parent:FindFirstChild("Humanoid") then
                    local target = game:GetService("Players"):GetPlayerFromCharacter(mouse.Target.Parent)
                    if target then
                        if not check_same_team(target) then
                            if wall_check(target) then
                                mouse1press()
                            end
                        end
                    end
                else
                    mouse1release()
                end
            end
        end
    end
end

run_service:BindToRenderStep(getgenv().update_loop_stepped_name, 199, stepped)