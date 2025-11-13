-- Criado por Grindmetal & DeepSeek
-- Baseado no script original de chrisneal72
-- https://github.com/chrisneal72/DCS-removeJunk-Scripts

local MapCleaner = {}


-- Configuração principal. Ajuste os parâmetros conforme necessário para maior flexibilidade.

local DEFAULT_RADIUS = 975360       -- metros (~975 km)
local DEFAULT_DELAY = 5             -- segundos
local DEFAULT_REPEAT_INTERVAL = 600 -- segundos (10min)

MapCleaner.config = {
    sphereCenter = { x = -114146.14614615, z = 287114.61461461 }, -- Centro da esfera
    radius = DEFAULT_RADIUS,
    delay = DEFAULT_DELAY,
    repeatInterval = DEFAULT_REPEAT_INTERVAL, -- ou nil para único disparo
}

-- Função utilitária de logging
local logHeader = "[MAP CLEANER]"
local function log(level, msg)
    env[level](string.format("%s [%s] %s", logHeader, level:upper(), msg))
end

-- Validação dos parâmetros
local function validateConfig(cfg)
    if not cfg.sphereCenter or not cfg.sphereCenter.x or not cfg.sphereCenter.z then
        log("error", "Parâmetros de sphereCenter inválidos!")
        return false
    end
    if not cfg.radius or cfg.radius <= 0 then
        log("error", "Raio de limpeza inválido!")
        return false
    end
    return true
end

-- Função principal da limpeza
function MapCleaner.performCleanup()
    log("info", "Iniciando limpeza do mapa...")

    if not validateConfig(MapCleaner.config) then return false end

    local sphere = {
        x = MapCleaner.config.sphereCenter.x,
        z = MapCleaner.config.sphereCenter.z
    }

    local success, height = pcall(function()
        return land.getHeight({ x = sphere.x, y = sphere.z })
    end)
    if not success or not height then
        log("error", "Falha ao calcular altura do terreno.")
        return false
    end
    sphere.y = height
    log("info", string.format("Centro da esfera: (X: %.2f | Y: %.2f | Z: %.2f)", sphere.x, sphere.y, sphere.z))

    local volS = {
        id = world.VolumeType.SPHERE,
        params = { point = sphere, radius = MapCleaner.config.radius }
    }

    local status, err = pcall(function()
        world.removeJunk(volS)
    end)

    if status then
        log("info", string.format("Limpeza realizada! Raio: %.2f km", volS.params.radius / 1000))
    else
        log("error", "Falha na remoção de objetos: " .. tostring(err))
    end

    if MapCleaner.config.repeatInterval then
        log("info", string.format("Próxima limpeza em %d seg.", MapCleaner.config.repeatInterval))
        mist.scheduleFunction(MapCleaner.performCleanup, {}, timer.getTime() + MapCleaner.config.repeatInterval)
    end
    return status
end

-- Função de inicialização
function MapCleaner.init()
    log("info", "Agendando limpeza inicial do mapa...")
    mist.scheduleFunction(MapCleaner.performCleanup, {}, timer.getTime() + MapCleaner.config.delay)
end

-- Comando de chat opcional para execução manual
function MapCleaner.enableChatCommand()
    trigger.action.outText("[MAP CLEANER] Comando de chat ativado! Use '-clearmap' no chat.", 10)
    -- Garante que só procesa o evento de chat relevante
    trigger.action.addOtherEvent(function(event)
        if event.id == world.event.S_EVENT_PLAYER_CHAT and event.text and event.text:lower() == "-clearmap" then
            log("info", "Comando manual de limpeza recebido via chat")
            trigger.action.outText("[MAP CLEANER] Executando limpeza manual!", 10)
            MapCleaner.performCleanup()
        end
    end)
end

-- Executa a inicialização
MapCleaner.init()
-- Para ativar comando manual, descomente:
-- MapCleaner.enableChatCommand()