-- ==========================================
-- LUPI ENGINE - SYSTEM FAILURE (FIXED)
-- ==========================================

-- Variáveis do Jogador
local player = { x = 24, y = 96, vy = 0, size = 8, grounded = false }

-- Física e Mundo
local gravity = 0.4
local jump_force = -5.8
local floor_y = 96
local score = 0
local speed = 2 -- Velocidade fixa por frame (sem usar dt)

-- Obstáculos
local obstacles = {}
local spawn_timer = 0

-- Sistema de Glitches / Falhas no Sistema
local glitch = {
    active = false,
    type = 0,
    timer = 0,
    next_trigger = 120,
    cam_x = 0,
    cam_y = 0
}

local game_over = false

-- ==========================================
-- LÓGICA DE ATUALIZAÇÃO
-- ==========================================

function update()
    if game_over then
        if btnp(0) or btnp(1) or btnp(4) then
            reset_game()
        end
        return
    end

    -- 1. Gerenciador de Glitches
    update_glitches()

    if glitch.active and glitch.type == 3 then
        return -- Efeito Freeze (congela o jogo)
    end

    -- 2. Gravidade e Movimento do Player
    local current_gravity = gravity
    if glitch.active and glitch.type == 2 then
        current_gravity = -gravity
    end

    player.vy = player.vy + current_gravity
    player.y = player.y + player.vy

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

    if (btnp(0) or btnp(4)) and player.grounded then
        if glitch.active and glitch.type == 2 then
            player.vy = -jump_force
        else
            player.vy = jump_force
        end
    end

    -- 3. Spawner de Obstáculos
    spawn_timer = spawn_timer + 1
    if spawn_timer > 70 then
        spawn_timer = 0
        local obs_type = math.random(1, 2)
        table.insert(obstacles, {
            x = 128,
            y = (obs_type == 1) and (floor_y + 2) or (floor_y - 20),
            w = 8,
            h = 6,
            type = obs_type
        })
    end

    -- 4. Atualização dos Obstáculos
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.x = obs.x - speed -- Removido o dt aqui

        if check_collision(player, obs) then
            game_over = true
        end

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
            glitch.timer = math.random(40, 90)
            glitch.next_trigger = math.random(120, 240)
        end
    end
end

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
    cls(0)

    camera(glitch.cam_x, glitch.cam_y)

    line(0, floor_y + 8, 128, floor_y + 8, 7)
    line(0, 16, 128, 16, 7)

    if glitch.active then
        for i = 1, 5 do
            -- Se rectf der erro aqui, mude para rectfill
            rectf(math.random(0, 120), math.random(20, 90), math.random(10, 30), 1, math.random(8, 14))
        end
        print("CRITICAL_ERR", 32, 4, 8)
    else
        print("SCORE: " .. score, 4, 4, 7)
    end

    for _, obs in ipairs(obstacles) do
        if obs.type == 1 then
            rectf(obs.x, obs.y, obs.w, obs.h, 8)
        else
            rectf(obs.x, obs.y, obs.w, obs.h, 10)
        end
    end

    rectf(player.x, player.y, player.size, player.size, 12)

    if game_over then
        camera(0, 0)
        rectf(16, 40, 96, 48, 0)
        -- Se rect der erro, pode ser que a engine só use line ou rectb
        rect(16, 40, 96, 48, 8) 
        print("SYSTEM CRASHED", 24, 48, 8)
        print("PRESS A TO REBOOT", 20, 64, 7)
    end
end
