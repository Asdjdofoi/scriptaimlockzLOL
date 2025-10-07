
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local aimlockEnabled = false
local currentTarget = nil

-- Функция поиска ближайшего игрока к курсору
local function findClosestPlayerToMouse()
    local mouse = LocalPlayer:GetMouse()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Пропускаем себя и мертвых игроков
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Получаем позицию игрока на экране
                local screenPoint, onScreen = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
                
                if onScreen then
                    -- Вычисляем расстояние от курсора до игрока на экране
                    local mousePos = Vector2.new(mouse.X, mouse.Y)
                    local playerPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (mousePos - playerPos).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Функция блокировки прицела
local function aimlock()
    if not aimlockEnabled or not currentTarget then return end
    
    local targetCharacter = currentTarget.Character
    if not targetCharacter then return end
    
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not targetHead then return end
    
    local camera = workspace.CurrentCamera
    local mouse = LocalPlayer:GetMouse()
    
    -- Плавное наведение камеры на цель
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
end

-- Обработка нажатия клавиши Z
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        aimlockEnabled = not aimlockEnabled
        
        if aimlockEnabled then
            currentTarget = findClosestPlayerToMouse()
            if currentTarget then
                print("Aimlock активирован на: " .. currentTarget.Name)
            else
                print("Цели не найдены")
                aimlockEnabled = false
            end
        else
            print("Aimlock деактивирован")
            currentTarget = nil
        end
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    if aimlockEnabled then
        if currentTarget and currentTarget.Character then
            aimlock()
        else
            -- Поиск новой цели если текущая потеряна
            currentTarget = findClosestPlayerToMouse()
        end
    end
end)

print("Aimlock скрипт загружен. Нажмите Z для включения/выключения")