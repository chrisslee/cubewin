-- Hide the iPhone status bar
display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() ) 

local map = {}   -- table representing each grid position
local resources = {}  -- table tracking the markers we are putting on the grid

-- The following is trickery to get the 255 scale rgb numbers (x/255)
local resourceColor = {{name = 'red', r=.835, g=.059, b=.145},
                       {name = 'blue', r=.2, g=.412, b=.909},
                       {name = 'green', r=.0, g=.6, b=.223},
                       {name = 'yellow', r=.933, g=.698, b=.066}}

local tileWidth = 128
local tileHeight = 64

local bg = display.newRect( display.screenOriginX,
                            display.screenOriginY, 
                            display.actualContentWidth, 
                            display.actualContentHeight)
 
bg.x = display.contentCenterX
bg.y = display.contentCenterY

-- this is to use the standard RGB color and still get a value between 0 and 1 for the setFillColor
bg:setFillColor( 000/255, 168/255, 254/255 ) 

-- display group that will hold grid
group = display.newGroup( )
group.x = display.contentCenterX -- center the grid on the screen

gamePiece = display.newGroup( )

-- draw a tile map to the screen
-- populate the tile map
function drawGrid()
   for row = 0, 5 do
      local gridRow = {}
      
      for col = 0, 5 do
        -- draw a diamond shaped tile
        local vertices = { 0,-16, -64,16, 0,48, 64,16 }
        local tile = display.newPolygon(group, 0, 0, vertices )

        -- outline the tile and make it transparent
        tile.strokeWidth = 1
        tile:setStrokeColor( 0, 1, 1 )
        tile.alpha = .25

        -- set the tile's x and y coordinates
        local x = col * tileHeight
        local y = row * tileHeight

        tile.x = x - y
        -- the first part of this equation is to move the y coordinate down 32 pixels (tileHeight/2)
        -- you have to do this because the second row of tiles is .5 above the first row
        tile.y = (tileHeight/2) + ((x + y)/2) 
        
        -- make a tile walkable
        --gridRow[col] = 0
      end
      -- add gridRow table to the map table
      map[row] = gridRow
   end
end

-- draw a marker on the grid
function drawResource(dx,dy, marker)
  local x = (display.contentWidth * 0.5 + ((dx - dy) * tileHeight)) 
  local y = (((dx + dy)/2) * tileHeight) - (tileHeight/2)
  local resource = display.newCircle( x, y, 20 )
  resource:setFillColor(marker.r, marker.g, marker.b)
  resource.alpha = 1
end

function buildResources()
  while #resources < 10 do

    local x = math.random(1,5)
    local y = math.random(1,5)
    local pTile = {x=math.random(1,5), y=math.random(1,5)} 
    local blocked = true

    if #resources > 0 then
      for i=1,#resources do
        if resources[i].x == pTile.x and resources[i].y == pTile.y then
          blocked = true
          break --end the loop because we found a conflict
        else
          blocked = false          
        end
      end
    else
      blocked = false
    end
    if blocked == false then
      resources[#resources+1] = {x=pTile.x, y=pTile.y}
      drawResource(pTile.x, pTile.y, resourceColor[math.random(1,4)])
    end
  end
end

drawGrid()
buildResources()
