----------------------------------------------------------------

--  INFORMATION ========= NOT TESTED =========

-- MOOSE MAP CLEANER (versão Grindmetal adaptada por GPT Scritper Learn moose)
-- Requer MOOSE.lua carregado antes.
-- Remove entulho (debris, crateras, etc.) dentro de uma esfera.

--  INFORMATION ========= NOT TESTED =========

----------------------------------------------------------------

-- Classe base do Cleaner
MapCleaner = {
    Version = "1.0",
    Center = { x = -114146.146, z = 287114.614 },
    Radius = 975360,          -- em metros (~975 km)
    Delay = 5,                -- tempo até a primeira limpeza (segundos)
    RepeatInterval = 600,     -- intervalo entre limpezas (segundos) | nil para executar uma vez
    Verbose = true
}

----------------------------------------------------------------
-- Logging helper (usa BASE:T para output no DCS.log)
----------------------------------------------------------------
function MapCleaner:Log(msg)
    if self.Verbose then
        BASE:T(string.format("[MAP CLEANER] %s", msg))
    end
end

----------------------------------------------------------------
-- Função principal: faz a limpeza de entulho
----------------------------------------------------------------
function MapCleaner:PerformCleanup()
    self:Log("Iniciando limpeza de mapa...")

    local sphere = {
        x = self.Center.x,
        z = self.Center.z
    }

    local success, height = pcall(function()
        return land.getHeight({ x = sphere.x, y = sphere.z })
    end)

    if not success or not height then
        self:Log("Erro ao calcular altura do terreno.")
        return false
    end

    sphere.y = height

    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = sphere,
            radius = self.Radius
        }
    }

    local ok, err = pcall(function()
        world.removeJunk(volS)
    end)

    if ok then
        self:Log(string.format("Limpeza concluída! Raio: %.1f km", self.Radius / 1000))
        MESSAGE:New(string.format("[MAP CLEANER] Mapa limpo! Raio %.1f km", self.Radius / 1000), 10):ToAll()
    else
        self:Log("Falha na limpeza: " .. tostring(err))
    end

    if self.RepeatInterval then
        self:Log(string.format("Agendando próxima limpeza em %d segundos...", self.RepeatInterval))
        SCHEDULER:New(nil, function() self:PerformCleanup() end, {}, self.RepeatInterval)
    end
end

----------------------------------------------------------------
-- Inicializa o sistema
----------------------------------------------------------------
function MapCleaner:Init()
    self:Log(string.format("Agendando primeira limpeza em %d segundos...", self.Delay))
    SCHEDULER:New(nil, function() self:PerformCleanup() end, {}, self.Delay)
    self:AddF10Command()
end

----------------------------------------------------------------
-- Comando F10 para acionar manualmente
----------------------------------------------------------------
function MapCleaner:AddF10Command()
    local MenuRoot = MENU_MISSION:New("🧹 MAP CLEANER")
    MENU_MISSION_COMMAND:New("Executar limpeza manual agora", MenuRoot, function()
        MESSAGE:New("[MAP CLEANER] Execução manual solicitada.", 10):ToAll()
        self:PerformCleanup()
    end)
end

----------------------------------------------------------------
-- Executa inicialização
----------------------------------------------------------------
MapCleaner:Init()
