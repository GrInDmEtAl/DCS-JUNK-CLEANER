-- Criador das alterações iniciais https://github.com/chrisneal72/DCS-removeJunk-Scripts
-- Ajustado por Grindmetal e DeepSeek[DeepThink R1 and Search], treinado para LUA DCS
--[[ 
    Versão com logging aprimorado e tratamento de erros
    Modificações principais:
    1. Logs detalhados em todas as etapas
    2. Verificação de variáveis nulas
    3. Tratamento de exceções
--]]

local flyingUnits = mist.makeUnitTable({'[blue][plane]','[blue][helicopter]','[red][plane]','[red][helicopter]'})
local eventListener = {}
local coordinatesCrash = nil
local volumeToPurify = nil

-- Configuração de logging
local logHeader = "[DEBRIS CLEANER]"
local function logInfo(msg)
    env.info(string.format("%s %s", logHeader, msg))
end

local function logError(msg)
    env.error(string.format("%s ERROR: %s", logHeader, msg))
end

function eventListener:onEvent(event)
    if event.id == 5 then -- Evento de crash
        logInfo("Crash detectado - Iniciando processamento")
        
        -- Verifica se o iniciador existe
        if not event.initiator then
            logError("Evento sem iniciador válido")
            return
        end

        -- Captura coordenadas
        local status, point = pcall(function()
            return event.initiator:getPoint()
        end)
        
        if not status or not point then
            logError("Falha ao obter coordenadas do crash")
            return
        end

        -- Calcula altura do terreno
        local success, height = pcall(function()
            return land.getHeight({x = point.x, y = point.z})
        end)
        
        if not success then
            logError(string.format("Falha ao calcular altura do terreno em X:%.2f Z:%.2f", point.x, point.z))
            return
        end

        coordinatesCrash = {
            x = point.x,
            z = point.z,
            y = height
        }

        logInfo(string.format("Coordenadas do crash: X:%.2f, Z:%.2f, Altura:%.2f", 
            coordinatesCrash.x, 
            coordinatesCrash.z, 
            coordinatesCrash.y))

        -- Cria volume de purificação
        volumeToPurify = {
            id = world.VolumeType.SPHERE,
            params = {
                point = coordinatesCrash,      -- Corrigido: Usa coordinatesCrash ao invés de currentZone.point
                radius = 8000
            }
        }

        logInfo(string.format("Volume criado - Raio: %dm em X:%.2f Z:%.2f", 
            volumeToPurify.params.radius,
            coordinatesCrash.x,
            coordinatesCrash.z))

        -- Agenda purificação
        local scheduleTime = timer.getTime() + 30
        mist.scheduleFunction(purifaction, {volumeToPurify}, scheduleTime)
        logInfo(string.format("Purificação agendada para t+%d segundos", scheduleTime - timer.getTime()))
    end
end

function purifaction(volume)
    logInfo("Iniciando processo de remoção de debris")
    
    local status, err = pcall(function()
        world.removeJunk(volume)
    end)
    
    if status then
        logInfo("Remoção de debris concluída com sucesso")
    else
        logError(string.format("Falha na remoção: %s", tostring(err)))
    end
end

-- Registra handler de eventos
world.addEventHandler(eventListener)
logInfo("Script inicializado e monitorando eventos de crash")
