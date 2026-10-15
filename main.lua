local player = { x = 24, y = 96, vy = 0, size = 8, grounded = false }
local gravity = 0.4
local jump_force = -5.8
local floor_y = 96
local score = 0
local speed = 2

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

            if (ui.btn(BTN_Z) or ui.btn(UP)) and player.grounded then
                if glitch.active and glitch.type == 2 then
                    player.vy = -jump_force
                else
                    player.vy = jump_force
                end
            end

            spawn_timer = spawn_timer + 1
            if spawn_timer > 70 then
                spawn_timer = 0
                local obs_type = math.random(1, 2)
                table.insert(obstacles, {
                    x = 128,
                    y = (obs_type == 1) and (floor_y + 2) or (floor_y - 20),
                    w = 8, h = 6, type = obs_type
                })
            end

            for i = #obstacles, 1, -1 do
                local obs = obstacles[i]
                obs.x = obs.x - speed

                if check_collision(player, obs) then
                    game_over = true
                end

                if obs.x < -10 then
                    table.remove(obstacles, i)
                    score = score + 10
                end
            end
        end
    end

    -- Limpa a tela
    ui.cls(0)

    -- Offset de câmera manual (já que não há função camera global declarada)
    local cx = glitch.cam_x
    local cy = glitch.cam_y

    -- Desenha Chão e Teto
    ui.line(0 + cx, floor_y + 8 + cy, 128 + cx, floor_y + 8 + cy, 7)
    ui.line(0 + cx, 16 + cy, 128 + cx, 16 + cy, 7)

    -- Efeitos visuais do glitch no fundo
    if glitch.active then
        for i = 1, 5 do
            local rx = math.random(0, 120)
            local ry = math.random(20, 90)
            local rw = math.random(10, 30)
            local c = math.random(8, 14)
            -- ui.rectfill recebe (x0, y0, x1, y1, col)
            ui.rectfill(rx + cx, ry + cy, rx + rw + cx, ry + 1 + cy, c)
        end
    end

    -- Desenha Obstáculos
    for _, obs in ipairs(obstacles) do
        local c = 8
        if obs.type == 2 then c = 10 end
        ui.rectfill(obs.x + cx, obs.y + cy, obs.x + obs.w + cx, obs.y + obs.h + cy, c)
    end

    -- Desenha Player
    ui.rectfill(player.x + cx, player.y + cy, player.x + player.size + cx, player.y + player.size + cy, 12)

    -- Tela de Game Over
    if game_over then
        ui.rectfill(16, 40, 112, 88, 0) -- Fundo preto
        ui.rect(16, 40, 112, 88, 8)     -- Borda vermelha
        ui.rectfill(24, 55, 104, 75, 8) -- Bloco de "Erro Fatal" vermelho simulando texto
    end
end

function update_glitches()
    if glitch.active then
        glitch.timer = glitch.timer - 1
        if glitch.type == 1 then
            glitch.cam_x = math.random(-3, 3); glitch.cam_y = math.random(-3, 3)
        else
            glitch.cam_x = 0; glitch.cam_y = 0
        end
        
        if glitch.timer <= 0 then
            glitch.active = false
            glitch.cam_x = 0; glitch.cam_y = 0
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
    return a.x < b.x + b.w and a.x + a.size > b.x and a.y < b.y + b.h and a.y + a.size > b.y
end

function reset_game()
    player.y = floor_y; player.vy = 0
    obstacles = {}; score = 0; spawn_timer = 0
    glitch.active = false; game_over = false
end
