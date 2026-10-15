-- Variáveis Iniciais
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
    -- ==========================================
    -- 1. UPDATE (LÓGICA)
    -- ==========================================
    if game_over then
        -- TROCADO AQUI: btnp por btn
        if btn(0) or btn(1) or btn(4) then
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

            -- TROCADO AQUI: btnp por btn
            if (btn(0) or btn(4)) and player.grounded then
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

    -- ==========================================
    -- 2. DRAW (RENDERIZAÇÃO)
    -- ==========================================
    cls(0)
    camera(glitch.cam_x, glitch.cam_y)

    line(0, floor_y + 8, 128, floor_y + 8, 7)
    line(0, 16, 128, 16, 7)

    if glitch.active then
        for i = 1, 5 do
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
        rect(16, 40, 96, 48, 8)
        print("SYSTEM CRASHED", 24, 48, 8)
        print("PRESS TO REBOOT", 20, 64, 7)
    end
end

-- ==========================================
-- FUNÇÕES AUXILIARES
-- ==========================================
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
        if glitch.next_
