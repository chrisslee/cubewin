-- Hide the iPhone status bar
display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() ) 

local map = {}   -- table representing each grid position

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
        
      end
      -- add gridRow table to the map table
      map[row] = gridRow
   end
end

function drawCube(dx,dy)
  local x = (display.contentWidth * 0.5 + ((dx - dy) * tileHeight)) 
  local y = (((dx + dy)/2) * tileHeight) - (tileHeight/2)
  local myImage = display.newImageRect( "assets/cube.png", tileWidth/2, tileHeight/1.5 )

  -- position the image
  myImage:translate( x, y )


end
drawGrid()
drawCube(4,4)

