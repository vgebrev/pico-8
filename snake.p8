pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- battle snakes
-- by vgebrev
snake_count = 2

function make_snake(i)
    local snake={}
    local x = flr(128 / (snake_count + 1) / 4) * 4 * i
    snake.index = i
    snake.x_vel = 0
    snake.y_vel = 1
    snake.segs = { { x = x, y = 64 }, { x = x, y = 60 }, { x = x, y = 56 } } 
    snake.score = 0
    snake.color = 14 - (i - 1) * 2 
    return snake;
end

function make_food()
    local food = {}
    local food_ok = false
    while (not food_ok) do
        food = { x = (flr(rnd(30)) + 1) * 4, y = (flr(rnd(28)) + 3) * 4 }
        food_ok = true
        for snake in all(snakes) do
            food_ok = food_ok and not check_collision_with_snake(food, snake)
        end
    end
    return food;
end

function _init()
    snakes = {}
    for i = 1, snake_count do
        add(snakes, make_snake(i))
    end
    food = make_food()
    ticks = 0
    speed = 1
end

function update_velocities()
    for snake in all(snakes) do
        if (btn(0, snake.index - 1) and snake.x_vel ~= 1) then 
            snake.x_vel = -1 
            snake.y_vel = 0
        end
        if (btn(1, snake.index - 1) and snake.x_vel ~= -1) then 
            snake.x_vel = 1
            snake.y_vel = 0 
        end
        if (btn(2, snake.index - 1) and snake.y_vel ~= 1) then 
            snake.y_vel = -1
            snake.x_vel = 0 
        end
        if (btn(3, snake.index - 1) and snake.y_vel ~= -1) then 
            snake.y_vel = 1
            snake.x_vel = 0 
        end
    end
end

function update_snakes()
    for snake in all(snakes) do
        for i = #snake.segs, 2, -1 do
            snake.segs[i].x = snake.segs[i - 1].x
            snake.segs[i].y = snake.segs[i - 1].y
        end
        snake.segs[1].x = min(124, max(snake.segs[1].x + snake.x_vel*4))
        snake.segs[1].y = min(124, max(snake.segs[1].y + snake.y_vel*4))
    end
end

function check_collision(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

function check_collision_with_snake(p, snake, exclude_head)
    for i = 1, #snake.segs do
        if (not (exclude_head and i == 1) and check_collision(snake.segs[i], p)) then return true end
    end
    return false
end

function grow_snake(snake)
    for i = 1, max(2, #snake.segs / 4) do
        add(snake.segs, { x = snake.segs[#snake.segs].x, y = snake.segs[#snake.segs].y })
    end
end

function update_speed()
    local score = 0
    for snake in all(snakes) do
        score += snake.score
    end
    
    if (score > 0 and score % 4 == 0) then
        speed = min(7, speed + 1)
    end
end

function update_food()
    for snake in all(snakes) do
        if (check_collision(snake.segs[1], food)) then  
            sfx(0, 3)      
            grow_snake(snake)
            food = make_food()
            snake.score += 1
            update_speed()
        end
    end
end

function check_death()
    local game_over = false
    for snake in all(snakes) do
        local head = snake.segs[1]
        if (check_collision({ x = 0, y = head.y }, head)) then snake.dead=true end
        if (check_collision({ x = 124, y = head.y }, head)) then snake.dead=true end
        if (check_collision({ x = head.x, y = 8 }, head)) then snake.dead=true end
        if (check_collision({ x = head.x, y = 124 }, head)) then snake.dead=true end

        for other_snake in all(snakes) do
            snake.dead = snake.dead or check_collision_with_snake(head, other_snake, snake.index == other_snake.index)
        end
       
        if (snake.dead) then
            snake.score = snake.score - 3
            sfx(1, 2)
            game_over = true
        end
    end
    return game_over
end

function _update()
    for snake in all(snakes) do
        if snake.dead then return end
    end
    update_velocities()
    ticks += 1
    if (ticks == 8 - speed) then 
        update_snakes()
        ticks=0
    end 
    update_food()
    game_over = check_death()
end

function draw_arena()
    rectfill(0, 0, 127, 127, 5)
    rectfill(0, 8, 127, 11, 6)
    rectfill(0, 8, 3, 127, 6)
    rectfill(0, 124, 127, 127, 6)
    rectfill(124, 8, 127, 127, 6)
end

function draw_food()
    rectfill(food.x, food.y, food.x + 3, food.y + 3, 7)
end

function draw_score(snake)
    print("p"..snake.index..": "..snake.score, 1 + (snake.index - 1) * 28, 1, snake.color)
end

function draw_game_over()
    rectfill(40, 56, 90, 68, 13)
    print("game over", 48, 60, 7)
end

function draw_snakes()
    for snake in all(snakes) do
        for seg in all(snake.segs) do
            rectfill(seg.x, seg.y, seg.x + 3, seg.y + 3, snake.color)
        end
        draw_score(snake)
    end
end

function _draw()
    draw_arena()    
    draw_food()
    draw_snakes()
    if (game_over) then draw_game_over() end
end
__sfx__
010200001b5511e5501a5401753013530175201b5201f510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001a0511b050130511c052000000f0530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
