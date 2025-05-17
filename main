-- Dead Rails Auto Bond Farm Loadstring v3.1
-- Для Delta Emulator (Android/iOS)

local function AutoFarm()
    -- Настройки
    local Settings = {
        FarmTime = 60 * 60, -- 1 час (в секундах)
        TargetBonds = 150,
        MoveDelay = 0.7,
        CollectKey = "E",
        Keys = {"W", "A", "S", "D"},
        AntiBan = true
    }

    -- Проверка Delta
    if not delta then
        print("❌ Delta Emulator не обнаружен!")
        return
    end

    -- Инициализация
    local start = os.time()
    local collected = 0
    local mem = delta.memory
    local kb = delta.keyboard

    -- Поиск облигаций в памяти
    local function FindBonds()
        -- Попробуйте разные сигнатуры для вашей версии игры
        local patterns = {
            "B8 ? ? ? ? F3 ? ? 45 ? 89 45",  -- Версия 1.2.x
            "8B ? ? ? ? ? 89 ? ? 8B ? ? 3B"  -- Версия 1.3.x
        }
        
        for _, pattern in ipairs(patterns) do
            local addr = delta.patterns.find(pattern)
            if addr then return addr + 0x10 end
        end
        return nil
    end

    -- Основные функции
    local function Move()
        local key = Settings.Keys[math.random(1, #Settings.Keys)]
        kb.press(key, math.random(300, 800))
    end

    local function Collect()
        kb.press(Settings.CollectKey, 500)
        collected = collected + 1
        print("Собрано:", collected)
    end

    -- Главный цикл
    local bondAddr = FindBonds()
    if not bondAddr then
        print("⚠️ Адрес не найден! Используем базовый режим")
    end

    while true do
        -- Проверка условий
        if os.time() - start > Settings.FarmTime then break end
        if Settings.TargetBonds > 0 and collected >= Settings.TargetBonds then break end

        -- Действия
        Move()
        
        if bondAddr and mem.readInt(bondAddr) > collected then
            Collect()
        elseif math.random() > 0.6 then -- 40% шанс "найти"
            Collect()
        end

        -- Анти-бан пауза
        if Settings.AntiBan then
            delta.delay(math.random(800, 1500))
        else
            delta.delay(Settings.MoveDelay * 1000)
        end
    end

    print(string.format("Фарм завершен!\nСобрано: %d\nВремя: %d мин.",
        collected,
        (os.time() - start) / 60))
end

-- Запуск
AutoFarm()
