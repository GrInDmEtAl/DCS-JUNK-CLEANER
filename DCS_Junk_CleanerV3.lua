-- Criado por Grindmetal & DeepSeek
-- Baseado no script original de chrisneal72
-- https://github.com/chrisneal72/DCS-removeJunk-Scripts

local MapCleaner = {}

-- Configurações principais
MapCleaner.config = {
    sphereCenter = { x = -114146.14614615, z = 287114.61461461 }, -- Centro da esfera
    radius = 975360, -- Raio de limpeza em metros (~975 km)
    delay = 5, -- Tempo até a primeira limpeza (segundos)
    repeatInterval = 600, -- Intervalo para repetição da limpeza em segundos (ex: 600 para 10 min). Coloque 'nil' para executar apenas uma vez.
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
    logInfo("Iniciando processo de limpeza do mapa")

    local sphere = {
        x = MapCleaner.config.sphereCenter.x,
        z = MapCleaner.config.sphereCenter.z
    }

    local success, height = pcall(function()
        return land.getHeight({ x = sphere.x, y = sphere.z })
    end)

    if not success or not height then
        logError("Falha ao calcular altura do terreno")
        return false
    end

    sphere.y = height
    logInfo(string.format("Centro da esfera - X: %.2f, Y: %.2f, Z: %.2f", sphere.x, sphere.y, sphere.z))

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
        logInfo(string.format("Limpeza concluída com sucesso! Raio de %.2f km", volS.params.radius / 1000))
    else
        logError("Falha na remoção: " .. tostring(err))
    end

    -- Se tiver repetição ativada, agendar próxima execução
    if MapCleaner.config.repeatInterval then
        logInfo(string.format("Agendando próxima limpeza em %d segundos", MapCleaner.config.repeatInterval))
        mist.scheduleFunction(MapCleaner.performCleanup, {}, timer.getTime() + MapCleaner.config.repeatInterval)
    end

    return status
end

-- Início programado
function MapCleaner.init()
    logInfo("Agendando limpeza inicial do mapa")
    mist.scheduleFunction(MapCleaner.performCleanup, {}, timer.getTime() + MapCleaner.config.delay)
end

-- NOT WORKING (Opcional Mas não está funcional a parte ) >> trigger.action.addOtherEvent(function(event) 
-- Comando de Chat para ativar manualmente durante a missão
function MapCleaner.enableChatCommand()
    trigger.action.outText("[MAP CLEANER] Comando de chat ativado! Use '-clearmap' no chat.", 10)
    -- Verificar mensagens do chat
    trigger.action.addOtherEvent(function(event)
        if event.id == world.event.S_EVENT_PLAYER_CHAT and event.text and event.text == "-clearmap" then
            logInfo("Comando manual de limpeza recebido via chat")
            trigger.action.outText("[MAP CLEANER] Executando limpeza manual do mapa!", 10)
            MapCleaner.performCleanup()
        end
    end)
end

-- Executa inicialização
MapCleaner.init()
-- (Opcional) Ativa comando de chat
-- MapCleaner.enableChatCommand()
