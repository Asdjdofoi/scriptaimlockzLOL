local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Игроки которых нужно пропускать
local SKIP_PLAYERS = {
    "anitemasylum007n7guy",
    "Roblaxian20002",
    player.Name -- себя
}

-- Флаги для управления работой скрипта
local isScriptRunning = true
local isPaused = false

-- Функция для проверки нужно ли пропускать игрока
local function shouldSkipPlayer(targetPlayer)
    for _, skipName in ipairs(SKIP_PLAYERS) do
        if targetPlayer.Name == skipName then
            return true
        end
    end
    return false
end

-- Функция для плавной телепортации
local function teleportToPlayer(targetPlayer)
    local character = player.Character
    local targetCharacter = targetPlayer.Character
    
    if not character or not targetCharacter then
        return false
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart or not targetRootPart then
        return false
    end
    
    -- Плавная телепортация
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
        CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 3)
    })
    
    tween:Play()
    tween.Completed:Wait()
    
    return true
end

-- Функция для симуляции кликов мыши
local function simulateMouseClicks(clickCount)
    for i = 1, clickCount do
        if not isScriptRunning or isPaused then
            break
        end
        
        -- Симуляция нажатия левой кнопки мыши
        mouse1click()
        wait(0.01)
    end
end

-- Обработчик нажатия клавиш
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        isScriptRunning = not isScriptRunning
        isPaused = false -- сбрасываем паузу при полной остановке
        print("Скрипт " .. (isScriptRunning and "запущен" or "остановлен"))
        
    elseif input.KeyCode == Enum.KeyCode.X then
        if isScriptRunning then
            isPaused = not isPaused
            print("Скрипт " .. (isPaused and "приостановлен" or "возобновлен"))
        end
    end
end

-- Основная функция
local function teleportAndClickToPlayers()
    while true do
        if not isScriptRunning then
            wait(0.1)
            continue
        end
        
        if isPaused then
            wait(0.1)
            continue
        end
        
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if not isScriptRunning or isPaused then
                break
            end
            
            if not shouldSkipPlayer(targetPlayer) and targetPlayer ~= player then
                local success = teleportToPlayer(targetPlayer)
                
                if success then
                    if not isScriptRunning or isPaused then
                        break
                    end
                    
                    wait(0.05)
                    simulateMouseClicks(3)
                    
                    if not isScriptRunning or isPaused then
                        break
                    end
                    
                    wait(0.1)
                end
            end
        end
        
        wait(0.5)
    end
end

-- Подключаем обработчик клавиш
UserInputService.InputBegan:Connect(onInputBegan)

-- Запускаем скрипт
spawn(function()
    teleportAndClickToPlayers()
end)

print("Скрипт запущен!")
print("Z - Вкл/Выкл скрипта")
print("X - Пауза/Продолжить")
print("Пропускаемые игроки: anitemasylum007n7guy, Roblaxian20002 и вы сами")