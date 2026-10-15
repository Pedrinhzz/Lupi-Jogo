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

function loop()
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
                    x = 500, -- Nasce fora da tela à direita
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
    ui.cls(0) -- Fundo preto

    local cx = glitch.cam_x
    local cy = glitch.cam_y

    -- Linhas do Teto e Chão
    ui.line(0 + cx, floor_y + cy, 480 + cx, floor_y + cy, 7)
    ui.line(0 + cx, 20 + cy, 480 + cx, 20 + cy, 7)

    -- Efeitos visuais do System Failure no fundo
    if glitch.active then
        for i = 1, 5 do
            local rx = math.random(0, 460)
            local ry = math.random(30, 200)
            local rw = math.random(20, 80)
            local c = math.random(8, 14)
            ui.rectfill(rx + cx, ry + cy, rx + rw + cx, ry + 2 + cy, c)
        end
    end

    -- Desenha Obstáculos
    for _, obs in ipairs(obstacles) do
        local c = 8 -- Vermelho para o chão
        if obs.type == 2 then c = 10 end -- Amarelo para aéreo
        ui.rectfill(obs.x + cx, obs.y + cy, obs.x + obs.w + cx, obs.y + obs.h + cy, c)
    end

    -- Desenha Player (Cubo Azul)
    ui.rectfill(
