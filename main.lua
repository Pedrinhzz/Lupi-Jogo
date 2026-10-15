-- ==========================================
-- LUPI ENGINE - SYSTEM FAILURE (GEOMETRY RUNNER)
-- ==========================================

-- Variáveis do Jogador
local player = {
    x = 24,
    y = 96,
    vy = 0,
    size = 8,
    grounded = false
}

-- Física e Mundo
local gravity = 0.4
local jump_force = -5.8
local floor_y = 96
local score = 0
local speed = 25

-- Obstáculos
local obstacles = {}
local spawn_timer = 0

-- Sistema de Glitches / Falhas no Sistema
local glitch = {
    active = false,
    type = 0,         -- 1: Cam Offset/Screen Shake, 2: Gravity Invert, 3: Freeze
    timer = 0,
    next_trigger = 120, -- Dispara a cada ~2 segundos (60 fps)
    cam_x = 0,
    cam_y = 0
}

local game_over = false

-- ==========================================
-- LÓGICA DE ATUALIZAÇÃO
-- ==========================================

function update(dt)
    if game_over then
        if btnp(0) or btnp(1) then
            reset_game()
        end
        return
    end

    -- 1. Gerenciador de Glitches / Falhas
    update_glitches()

    -- Se o glitch for FREEZE (tipo 3), trava a atualização física por alguns frames
    if glitch.active and glitch.type == 3 then
        return
    end

    -- 2. Gravidade e Movimento do Player
    local current_gravity = gravity
    if glitch.active and glitch.type == 2 then
        current_gravity = -gravity -- Gravidade Invertida
    end

    player.vy = player.vy + current_gravity
    player.y = player.y + player.vy

    -- Colisão com Chão / Teto (dependendo da gravidade)
    if player.y >= floor_y then
        player.y = floor_y
        player.vy = 0
        player.grounded = true
    elseif player.y <= 16 then
        player.y = 16
        player.vy = 0
        player.grounded = true
    else
        player.grounded = false
    end

    -- Pulo (Botão A / Espaço / Seta para Cima)
    if (btnp(0) or btnp(4)) and player.grounded then
        if glitch.active and glitch.type == 2 then
            player.vy = -jump_force -- Pulo para baixo se invertido
        else
            player.vy = jump_force
        end
    end

    -- 3. Spawner de Obstáculos
    spawn_timer = spawn_timer + 1
    if spawn_timer > 70 then
        spawn_timer = 0
        local obs_type = math.random(1, 2) -- 1: Espinho no chão, 2: Bloco aéreo
        table.insert(obstacles, {
            x = 128,
            y = (obs_type == 1) and (floor_y + 2) or (floor_y - 20),
            w = 8,
            h = 6,
            type = obs_type
        })
    end

    -- 4. Atualização e Colisão dos Obstáculos
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.x = obs.x - (speed * dt)

        -- Checagem AABB (Colisão)
        if check_collision(player, obs) then
            game_over = true
        end

        -- Remove obstáculos fora da tela
        if obs.x < -10 then
            table.remove(obstacles, i)
            score = score + 10
        end
    end
end

-- ==========================================
-- SISTEMA DE FALHAS (GLITCHES)
-- ==========================================

function update_glitches()
    if glitch.active then
        glitch.timer = glitch.timer - 1
        
        -- Efeito visual de tremor de câmera no tipo 1
        if glitch.type == 1 then
            glitch.cam_x = math.random(-3, 3)
            glitch.cam_y = math.random(-3, 3)
        else
            glitch.cam_x = 0
            glitch.cam_y = 0
        end

        if glitch.timer <= 0 then
            glitch.active = false
            glitch.cam_x = 0
            glitch.cam_y = 0
        end
    else
        glitch.next_trigger = glitch.next_trigger - 1
        if glitch.next_trigger <= 0 then
            glitch.active = true
            glitch.type = math.random(1, 3)
            glitch.timer = math.random(40, 90) -- Duração do glitch
            glitch.next_trigger = math.random(120, 240) -- Tempo até o próximo
        end
    end
end

-- Auxiliar de Colisão
function check_collision(a, b)
    return a.x < b.x + b.w and
           a.x + a.size > b.x and
           a.y < b.y + b.h and
           a.y + a.size > b.y
end

function reset_game()
    player.y = floor_y
    player.vy = 0
    obstacles = {}
    score = 0
    spawn_timer = 0
    glitch.active = false
    game_over = false
end

-- ==========================================
-- RENDERIZAÇÃO (DRAW)
-- ==========================================

function draw()
    cls(0) -- Limpa tela

    -- Aplica Offset de Câmera (Glitch Visual)
    camera(glitch.cam_x, glitch.cam_y)

    -- Desenha Chão e Teto
    line(0, floor_y + 8, 128, floor_y + 8, 7)
    line(0, 16, 128, 16, 7)

    -- Artefatos Visuais de System Failure no Background
    if glitch.active then
        for i = 1, 5 do
            rectf(math.random(0, 120), math.random(20, 90), math.random(10, 30), 1, math.random(8, 14))
        end
        print("CRITICAL_ERR", 32, 4, 8)
    else
        print("SCORE: " .. score, 4, 4, 7)
    end

    -- Desenha Obstáculos
    for _, obs in ipairs(obstacles) do
        if obs.type == 1 then
            -- Espinho (Triângulo/Bloco Vermelho)
            rectf(obs.x, obs.y, obs.w, obs.h, 8)
        else
            -- Obstáculo aéreo (Amarelo)
            rectf(obs.x, obs.y, obs.w, obs.h, 10)
        end
    end

    -- Desenha Jogador (Cubo Azul)
    rectf(player.x, player.y, player.size, player.size, 12)

    -- Tela de Game Over
    if game_over then
        camera(0, 0)
        rectf(16, 40, 96, 48, 0)
        rect(16, 40, 96, 48, 8)
        print("SYSTEM CRASHED", 24, 48, 8)
        print("PRESS A TO REBOOT", 20, 64, 7)
    end
end
