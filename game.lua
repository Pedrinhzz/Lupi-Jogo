-- ===========================
-- CONFIGURAÇÃO E PALETA Lupi
-- ===========================
local Palette = {
    0x0000, -- 0: Preto
    0x0000, -- 1
    0x0000, -- 2
    0x0000, -- 3
    0x0000, -- 4
    0x0000, -- 5
    0x0000, -- 6
    0x7FFF, -- 7: Branco
    0x7C00, -- 8: Vermelho puro
    0x0000, -- 9
    0x03FF, -- 10: Amarelo
    0x0000, -- 11
    0x001F, -- 12: Azul puro
    0x0000, -- 13
    0x7C1F, -- 14: Roxo
    0x0000  -- 15
}

-- ===========================
-- VARIÁVEIS GLOBAIS
-- ===========================
local player = { x = 60, y = 200, vy = 0, size = 20, grounded = false }
local gravity = 0.6
local jump_force = -11.0
local floor_y = 220
local score = 0
local speed = 5

local obstacles = {}
local spawn_timer = 0
local glitch = { active = false, type = 0, timer = 0, next_trigger = 120, cam_x = 0, cam_y = 0 }
local game_over = false

-- ATENÇÃO: Substitua estas variáveis pelos seus assets reais carregados pelo motor
local spr_player = {} 
local spr_obstacle = {} 

-- ===========================
-- LOOP PRINCIPAL
-- ===========================
function update(frame)
    for i = 1, #Palette do
        ui.palset(i - 1, Palette[i])
    end

    if game_over then
        if ui.btnp(BTN_Z) or ui.btnp(UP) then
            reset_game()
        end
    else
        update_glitches()

        if not (glitch.active and glitch.type == 3) then
            local current_gravity = gravity
            if glitch.active and glitch.type == 2 then current_gravity = -gravity end

            player.vy = player.vy + current_gravity
            player.y = player.y + player.vy

            -- Colisão Chão e Teto
            if player.y >= floor_y - player.size then
                player.y = floor_y - player.size
                player.vy = 0
                player.grounded = true
            elseif player.y <= 20 then
                player.y = 20
                player.vy = 0
                player.grounded = true
            else
                player.grounded = false
            end

            -- Pulo
            if (ui.btn(BTN_Z) or ui.btn(UP)) and player.grounded then
                if glitch.active and glitch.type == 2 then
                    player.vy = -jump_force
                else
                    player.vy = jump_force
                end
            end

            -- Geração de Obstáculos
            spawn_timer = spawn_timer + 1
            if spawn_timer > 60 then
                spawn_timer = 0
                local obs_type = math.random(1, 2)
                table.insert(obstacles, {
                    x = 500,
                    y = (obs_type == 1) and (floor_y - 20) or (floor_y - 80),
                    w = 20, h = 20, type = obs_type
                })
            end

            for i = #obstacles, 1, -1 do
                local obs = obstacles[i]
                obs.x = obs.x - speed

                if check_collision(player, obs) then
                    game_over = true
                end

                if obs.x < -40 then
                    table.remove(obstacles, i)
                    score = score + 10
                end
            end
        end
    end

    -- ===========================
    -- RENDERIZAÇÃO
    -- ===========================
    ui.cls(0)

    local cx = glitch.cam_x
    local cy = glitch.cam_y

    -- Linhas do Teto e Chão
    ui.line(0 + cx, floor_y + cy, 480 + cx, floor_y + cy, 7)
    ui.line(0 + cx, 20 + cy, 480 + cx, 20 + cy, 7)

    -- Efeitos visuais
    if glitch.active then
        -- Texto indic
