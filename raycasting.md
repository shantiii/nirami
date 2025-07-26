# Raycasting in `nirami.p8`

This document breaks down the raycasting implementation used in `nirami.p8` to render a 3D-like environment from a 2D map.

## The Core Concept

Raycasting is a rendering technique that creates a 3D perspective from a 2D map. The fundamental idea is to cast out rays from the player's position for every vertical column of pixels on the screen. The distance to the first object each ray hits determines how tall that vertical slice of the object should be drawn.

The entire process happens inside the `_draw()` function.

## The Main Loop

The rendering process starts with a loop that iterates through each vertical column of the screen, from `i=0` to `i=127` (the width of the PICO-8 screen).

```lua
-- raycasting loop
for i=0,127 do
    -- ... cast a ray and draw a wall slice for column i
end
```

For each column `i`, we perform the following steps:

### 1. Calculate the Ray's Angle

First, we calculate the angle of the ray for the current screen column `i`. The player's view is a field of view (FOV). This code starts the ray angle slightly to the left of the player's direction (`p.a - 0.2`) and sweeps it across the FOV.

```lua
local ray_a = p.a - 0.2 + (i/128) * 0.4
```

### 2. Cast the Ray (Ray Marching)

Next, we "march" the ray forward in small steps from the player's position (`p.x`, `p.y`) until it hits a wall or exceeds a maximum distance.

-   We get the direction of the ray using `cos(ray_a)` and `sin(ray_a)`.
-   The `while` loop increments the ray's position (`ray_x`, `ray_y`) and the total distance (`dist`) traveled.
-   In each step, we check the map tile at the ray's current coordinates. If `map[flr(ray_y)][flr(ray_x)]` is anything other than `0`, we've hit a wall.

```lua
local dist = 0
local hit = 0
local ray_x, ray_y = p.x, p.y
local ray_step_x = cos(ray_a) * 0.02
local ray_step_y = sin(ray_a) * 0.02

while(hit==0 and dist < 20) do
    ray_x += ray_step_x
    ray_y += ray_step_y
    dist += 0.02
    hit = map[flr(ray_y)][flr(ray_x)]
end
```

### 3. Correct for Fisheye Distortion

If we use the direct `dist` value, walls will appear curved, creating a "fisheye" effect. To fix this, we multiply the distance by the cosine of the angle between the ray and the player's direct line of sight. This gives us the perpendicular distance, which is what we need for a correct projection.

```lua
local ca = p.a - ray_a
dist *= cos(ca)
```

### 4. Calculate Wall Height and Draw the Slice

Once we have the corrected distance, we can calculate the height of the wall slice for the current screen column `i`.

-   The wall height `h` is inversely proportional to the distance. The `64 / dist` formula scales it to the screen.
-   `y1` and `y2` are the top and bottom screen coordinates for the vertical line.
-   The color `col` is determined by the value of `hit` (the type of wall).
-   Finally, `line(i, y1, i, y2, col)` draws the actual vertical slice.

```lua
local h = 64 / dist
local y1 = 64 - h
local y2 = 64 + h

local col = 7
if (hit == 2) col = 8
if (hit == 3) col = 12

line(i, y1, i, y2, col)
```

### 5. Simple Shading

To add a sense of depth, we darken the walls that are farther away by drawing a darker line over the original slice.

```lua
if (dist > 4)  line(i, y1, i, y2, 1) -- dark grey
if (dist > 7)  line(i, y1, i, y2, 0) -- black
```

This entire process is repeated for all 128 columns of the screen, creating the final 3D scene from a simple 2D map array. 
