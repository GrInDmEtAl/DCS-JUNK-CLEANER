-- Criado por Grindmetal & DeepSeek
-- Based on the original script by chrisneal72
-- https://github.com/chrisneal72/DCS-removeJunk-Scripts

local MapCleaner = {}

-- Main configurations
MapCleaner.config = {
    sphereCenter = { x = -114146.14614615, z = 287114.61461461 }, -- Centro da esfera
    radius = 975360, -- Cleaning radius in meters (~975 km)
    delay = 5, -- Time until first cleaning (seconds)
    repeatInterval = 600, -- Interval for repeat cleaning in seconds (e.g. 600 for 10 min). Set to ‘nil’ to run only once.
}

-- Logging
local logHeader = "[MAP CLEANER]"
local function logInfo(msg)
    env.info(string.format("%s %s", logHeader, msg))
end

local function logError(msg)
    env.error(string.format("%s ERROR: %s", logHeader, msg))
end

-- Função principal de limpeza
function MapCleaner.performCleanup()
    logInfo("Starting the map cleaning process")

    local sphere = {
        x = MapCleaner.config.sphereCenter.x,
        z = MapCleaner.config.sphereCenter.z
    }

    local success, height = pcall(function()
        return land.getHeight({ x = sphere.x, y = sphere.z })
    end)

    if not success or not height then
        logError("Failure to calculate ground height")
        return false
    end

    sphere.y = height
    logInfo(string.format("Center of the sphere - X: %.2f, Y: %.2f, Z: %.2f", sphere.x, sphere.y, sphere.z))

    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = sphere,
            radius = MapCleaner.config.radius
        }
    }

    local status, err = pcall(function()
        world.removeJunk(volS)
    end)

    if status then
        logInfo(string.format("Cleaning successfully completed! Radius of %.2f km", volS.params.radius / 1000))
    else
        logError("Falha na remoção: " .. tostring(err))
    end

    -- If repeat is enabled, schedule next run
    if MapCleaner.config.repeatInterval then
        logInfo(string.format("Scheduling next cleaning in %d seconds", MapCleaner.config.repeatInterval))
        mist.scheduleFunction(MapCleaner.performCleanup, {}, timer.getTime() + MapCleaner.config.repeatInterval)
    end

    return status
end

-- Scheduled start
function MapCleaner.init()
    logInfo("Scheduling initial map cleaning")
    mist.scheduleFunction(MapCleaner.performCleanup, {}, timer.getTime() + MapCleaner.config.delay)
end

-- NOT WORKING ( Optional but not functional separately ) >> trigger.action.addOtherEvent(function(event) 
-- Chat command to activate manually during the mission
function MapCleaner.enableChatCommand()
    trigger.action.outText("[MAP CLEANER] Chat command activated! Use ‘-clearmap’ in chat.", 10)
    -- Verificar mensagens do chat
    trigger.action.addOtherEvent(function(event)
        if event.id == world.event.S_EVENT_PLAYER_CHAT and event.text and event.text == "-clearmap" then
            logInfo("Manual cleaning command received via chat")
            trigger.action.outText("[MAP CLEANER] Running manual map cleaning!", 10)
            MapCleaner.performCleanup()
        end
    end)
end

-- Executes initialization
MapCleaner.init()
-- (Optional) Activate chat command
-- MapCleaner.enableChatCommand()
