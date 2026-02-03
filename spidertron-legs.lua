-- Copyright 2020 jeff.s

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- (Code adapted from spidertron-leg-count mod by jeff.s)
local leg_count = 48
local function spidertron_angle_to_base_leg(degrees)
    local offset = 33.22
    if degrees <= offset then
        return 3
    elseif degrees <= 90 then
        return 4
    elseif degrees <= 180 - offset then
        return 8
    elseif degrees <= 180 then
        return 7
    elseif degrees <= 180 + offset then
        return 6
    elseif degrees <= 270 then
        return 5
    elseif degrees <= 360 - offset then
        return 1
    else
        return 2
    end
end
local function spidertron_generate_blocking_legs(index)
    return {
        (index - 2) % leg_count + 1,
        index % leg_count + 1
    }
end
local function spidertron_generate_leg_at_angle(degrees, blocking_legs, ground_distance, index)
    if blocking_legs == nil then
        blocking_legs = {}
    end
    if ground_distance == nil then
        ground_distance = 3.25
    end
    local base_leg_index = spidertron_angle_to_base_leg(degrees)
    radians = math.rad(degrees)
    local mount_x = 25 * math.cos(radians)
    local mount_y = 25 * math.sin(radians)
    local ground_x = ground_distance * math.cos(radians)
    local ground_y = ground_distance * math.sin(radians)
    local base_leg_triggers = {}
    for _, leg in pairs(data.raw["spider-vehicle"].spidertron.spider_engine.legs) do
        table.insert(base_leg_triggers, table.deepcopy(leg.leg_hit_the_ground_trigger))
    end
    return {
        leg = "spidertron-leg-" .. base_leg_index,
        mount_position = util.by_pixel(mount_x, mount_y),
        ground_position = {ground_x, ground_y},
        blocking_legs = blocking_legs,
        leg_hit_the_ground_trigger = base_leg_triggers[base_leg_index],
        walking_group = index % 3 + 1
    }
end
local function spidertron_generate_legs(ground_distance)
    local legs = {}
    for i = 1, leg_count do
        table.insert(legs, spidertron_generate_leg_at_angle((90 + 360 / leg_count * (i - 1)) % 360, spidertron_generate_blocking_legs(i), ground_position, i))
    end
    return legs
end
data.raw["spider-vehicle"].spidertron.spider_engine.legs = spidertron_generate_legs()