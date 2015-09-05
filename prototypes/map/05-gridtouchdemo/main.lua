-----------------------------------------------------------------------------------------
--
-- main.lua
-- http://www.webdevils.com/corona-tile-matching-and-triple-town/
-----------------------------------------------------------------------------------------

-- Your code here

local TILE_ROWS = 6
local TILE_COLS = 6
local TILE_SIZE = 50
local TILE_MARGIN = 1

local tile_array = {}
local color_array = {} -- An array to store colors

local game_group = display.newGroup()


-- Make a function to return a color
local function Color( red, green, blue )
	return {r=red, g=green, b=blue}
end 

table.insert( color_array, Color(255, 0, 0) )
table.insert( color_array, Color(0, 255, 0) )
table.insert( color_array, Color(0, 0, 255) )

table.insert( color_array, Color(255, 255, 0) )
table.insert( color_array, Color(255, 0, 255) )
table.insert( color_array, Color(0, 255, 255) )





local function touch_tile( event )
	local phase = event.phase
	
	if phase == "ended" then 
		local tile = event.target
		if tile.is_empty then 
			tile.is_empty = false
			tile.color_index = 1
		else 
			tile.color_index = tile.color_index + 1
		end 
		
		local r = color_array[ tile.color_index ].r
		local g = color_array[ tile.color_index ].g
		local b = color_array[ tile.color_index ].b
		
		tile:setFillColor( r, g, b )
	end 
end


local function Tile()
	local tile = display.newRect( 0, 0, TILE_SIZE, TILE_SIZE )
	tile:setFillColor( 255, 255, 255, 100 )
	return tile
end 


local function make_grid()
	local tile_spacing = TILE_SIZE + TILE_MARGIN
	local offset_x = ( display.contentWidth - ( tile_spacing * TILE_COLS ) ) / 2
	offset_x = TILE_SIZE / 2 - offset_x
	
	for row = 1, TILE_ROWS, 1 do 
		local row_array = {}
		for col = 1, TILE_COLS, 1 do 
			local tile = Tile()
			game_group:insert( tile )
			tile.x = ( col * tile_spacing ) - offset_x
			tile.y = row * tile_spacing
			tile.row = row
			tile.col = col 
			
			tile.is_empty = true -- set this tile to empty
			tile.color_index = 0
			
			tile:addEventListener( "touch", touch_tile )
			table.insert( row_array, tile )
		end 
		table.insert( tile_array, row_array )
	end 
end 

make_grid()
