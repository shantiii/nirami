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

	-- sprite data: x,y position and sprite id
	sprites={
		{x=4.5, y=4.5, id=8},
		{x=4.5, y=6.5, id=8}
	}
end

-- custom sort for sprites
function bubble_sort(t)
	local n=#t
	if n < 2 then return end
	for i=1,n-1 do
		for j=1,n-i do
			if t[j].dist < t[j+1].dist then
				t[j],t[j+1] = t[j+1],t[j]
			end
		end
	end
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

	local zbuffer={}

	-- raycasting loop
	for i=0,127 do
		local ray_a = p.a - 0.2 + (i/128) * 0.4
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
			if (flr(ray_y) >= 1 and flr(ray_y) <= #map and flr(ray_x) >= 1 and flr(ray_x) <= #map[flr(ray_y)]) then
				hit = map[flr(ray_y)][flr(ray_x)]
			else
				hit = 1 -- hit boundary
				dist = 20
			end
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
		zbuffer[i]=dist
	end

	-- sort sprites by distance
	for s in all(sprites) do
		s.dist = ((p.x-s.x)*(p.x-s.x) + (p.y-s.y)*(p.y-s.y))
	end
	bubble_sort(sprites)

	-- draw sprites
	for s in all(sprites) do
		-- relative position to player
		local sx = s.x - p.x
		local sy = s.y - p.y

		-- rotate by inverse player angle
		local sz = sx * cos(-p.a) - sy * sin(-p.a) -- depth
		local sx_rot = sx * sin(-p.a) + sy * cos(-p.a) -- perpendicular

		-- only draw if in front and on screen
		if (sz > 0.5) then
			-- project to screen
			local scale = 32 / sz
			local screen_x = 64 + (sx_rot * 128 / sz)
			
			-- sprite dimensions
			local sprite_w = 8 * scale
			local sprite_h = 8 * scale
			local start_x = screen_x - sprite_w/2
			local start_y = 64 - sprite_h/2 + 32/sz -- offset to sit on floor

			-- draw sprite one vertical line at a time
			for i=0,sprite_w-1 do
				local column = flr(start_x + i)
				-- check zbuffer and screen bounds
				if(column>=0 and column<128 and sz < zbuffer[column]) then
					local tex_u = flr(i/sprite_w * 8)
					sspr(
						s.id*8+tex_u, 0, -- source x,y
						1,8, -- source w,h
						column, start_y, -- dest x,y
						1, sprite_h -- dest w,h
					)
				end
			end
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000d6d0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000d666d00000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000d66666d0000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000d66666d0000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000d66666d0000000000000000000000000000000000000000000000000
007007000000000000000000000000000000000000000000000000000000000000000000d666d00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000d6d0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
