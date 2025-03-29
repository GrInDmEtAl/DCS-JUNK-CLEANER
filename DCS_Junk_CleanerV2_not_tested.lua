-- Criador das alterações iniciais https://github.com/chrisneal72/DCS-removeJunk-Scripts
-- Ajustado por Grindmetal e DeepSeek[DeepThink R1 and Search], treinado para LUA DCS
-- Sistema de logging         V2 NOT TESTED
-- Original https://github.com/chrisneal72/DCS-removeJunk-Scripts/blob/main/2_OneSphereCleansThemAll.lua
local logHeader = "[MAP CLEANER]"
local function logInfo(msg)
    env.info(string.format("%s %s", logHeader, msg))
end

local function logError(msg)
    env.error(string.format("%s ERROR: %s", logHeader, msg))
end

function CleanUpMap()
    -- Coordenadas da esfera
    local sphere = {
        x = -114146.14614615,
        z = 287114.61461461
    }
    
    -- Log inicial
    logInfo("Iniciando processo de limpeza do mapa")
    logInfo(string.format("Coordenadas base - X: %.2f, Z: %.2f", sphere.x, sphere.z))

    -- Calcula altura do terreno com tratamento de erro
    local success, height = pcall(function()
        return land.getHeight({x = sphere.x, y = sphere.z})
    end)
    
    if not success or not height then
        logError("Falha ao calcular altura do terreno")
        return false
    end
    
    sphere.y = height
    logInfo(string.format("Altura do terreno calculada: %.2f metros", sphere.y))

    -- Cria volume esférico
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = sphere,
            radius = 975360
        }
    }

    -- Agendamento com atraso de 5 segundos
    local delay = 5
    mist.scheduleFunction(function()
        logInfo("Iniciando remoção de debris...")
        logInfo(string.format("Raio de limpeza: %.2f km", volS.params.radius / 1000))
        
        local status, err = pcall(function()
            world.removeJunk(volS) -- Operação crítica com tratamento de erro
        end)
        
        if status then
            logInfo("Limpeza concluída com sucesso!")
        else
            logError("Falha na remoção: " .. tostring(err))
        end
    end, {}, timer.getTime() + delay)

    logInfo(string.format("Operação agendada para daqui a %d segundos", delay))
    return true
end

-- Executa a função principal
CleanUpMap()
