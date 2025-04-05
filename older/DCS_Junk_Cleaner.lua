-- Criador das alterações iniciais https://github.com/chrisneal72/DCS-removeJunk-Scripts
-- Ajustado por Grindmetal e DeepSeek[DeepThink R1 and Search], treinado para LUA DCS
-- Configuração de logging
local logHeader = "[JUNK CLEANER]"
local function logInfo(msg)
    env.info(string.format("%s %s", logHeader, msg))
end

local function logError(msg)
    env.error(string.format("%s ERROR: %s", logHeader, msg))
end

-- Função principal de limpeza
local function scheduleJunkRemoval()
    -- Coordenadas da esfera
    local sphere = {
        x = -114146.14614615,
        z = 287114.61461461
    }
    
    -- Calcula altura do terreno com tratamento de erro
    local success, height = pcall(function()
        return land.getHeight({x = sphere.x, y = sphere.z})
    end)
    
    if not success then
        logError("Falha ao calcular altura do terreno")
        return
    end
    
    sphere.y = height
    
    logInfo(string.format("Esfera definida em X:%.2f, Z:%.2f, Altura:%.2f", 
        sphere.x, sphere.z, sphere.y))

    -- Cria volume de limpeza
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = sphere,
            radius = 975360
        }
    }

    -- Agenda limpeza para 10 segundos após execução
    local delay = 10  -- Tempo em segundos
    mist.scheduleFunction(function()
        logInfo("Iniciando remoção de debris...")
        
        local status, err = pcall(function()
            world.removeJunk(volS)
        end)
        
        if status then
            logInfo("Remoção concluída com sucesso!")
        else
            logError("Falha na remoção: " .. tostring(err))
        end
    end, {}, timer.getTime() + delay)

    logInfo(string.format("Limpeza agendada para daqui a %d segundos", delay))
end

-- Inicia o processo
scheduleJunkRemoval()
