pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()
	-- player position and angle
	p={x=8.5,y=8.5,a=0}

	-- map data. 0=empty, 1=wall
	map={
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,1,0,0,2,0,0,0,0,2,0,0,1,0,1},
		{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
		{1,0,1,0,0,2,0,0,0,0,2,0,0,1,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,3,0,0,0,0,0,0,0,0,3,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,3,0,0,0,0,0,0,0,0,3,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,1,1,1,1,1,0,0,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	}
end

function _update()
	-- turn left/right
	if (btn(0)) p.a-=.02
	if (btn(1)) p.a+=.02

	-- move forward/backward
	local move_x = cos(p.a) * 0.1
	local move_y = sin(p.a) * 0.1

	if (btn(2)) then
		if (map[flr(p.y)][flr(p.x+move_x*2)]==0) p.x+=move_x
		if (map[flr(p.y+move_y*2)][flr(p.x)]==0) p.y+=move_y
	end

	if (btn(3)) then
		if (map[flr(p.y)][flr(p.x-move_x*2)]==0) p.x-=move_x
		if (map[flr(p.y-move_y*2)][flr(p.x)]==0) p.y-=move_y
	end
end

function _draw()
	-- floor and ceiling
	rectfill(0,0,127,63,0) -- ceiling
	rectfill(0,64,127,127,11) -- floor

	-- raycasting loop
	for i=0,127 do
		local ray_a = p.a - 0.125 + (i/128) * 0.25
		local dist = 0
		local hit = 0
		local hit_x, hit_y

		-- cast ray
		local ray_x, ray_y = p.x, p.y
		local ray_step_x = cos(ray_a) * 0.02
		local ray_step_y = sin(ray_a) * 0.02

		while(hit==0 and dist < 20) do
			ray_x += ray_step_x
			ray_y += ray_step_y
			dist += 0.02
			hit = map[flr(ray_y)][flr(ray_x)]
		end

		-- draw wall slice
		if hit > 0 then
			-- fisheye correction
			local ca = p.a - ray_a
			dist *= cos(ca)
			
			-- calculate wall height and position
			local h = 64 / dist
			local y1 = 64 - h
			local y2 = 64 + h

			-- set wall color based on type
			local col = 7
			if (hit == 2) col = 8
			if (hit == 3) col = 12
			
			-- draw the line
			line(i, y1, i, y2, col)

			-- simple shading based on distance
			if (dist > 4)  line(i, y1, i, y2, 1)
			if (dist > 7)  line(i, y1, i, y2, 0)
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
