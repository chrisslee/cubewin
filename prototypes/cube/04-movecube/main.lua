-- Hide the iPhone status bar
display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() ) 
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")
local walkable = 0 -- used by Jumper to mark obstacles
local map = {}   -- table representing each grid position
local player = {}
local pathToWalk = {}

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

function getCoordinates(dx,dy)
  local x = (display.contentWidth * 0.5 + ((dx - dy) * tileHeight)) 
  local y = (((dx + dy)/2) * tileHeight) - (tileHeight/2)
  return x,y
end

function nextStep(dx,dy)
  local cx,cy = getCoordinates(dx,dy)
end

function walkPath( path )
  pth.idx = 2
  if path then
      for node, count in path:nodes() do
        print(node:getX().. ', ' .. node:getY()) 
        nextStep(node:getX(), node:getY())
        path[#path+1] = {x=dx, y=dy}
      end
      if #path > 1 then
        local function nextStep(obj)
      if path.idx < #path+1 then
        local pos = pixelXYFromGridXY(path[path.idx].x,path[path.idx].y)
        transition.to(path, {time=500, x=pos.x, y=pos.y, onComplete=nextStep})
     --else
     --  mapStartPos = tank.myPath[tank.idx-1]
     --end
      path.idx = path.idx + 1
    end
    nextStep()
  end
end

function getPath( tile )
   -- create a Jumper Grid object by passing in our map table
   local grid = Grid(map)

   local pather = Pathfinder(grid, 'ASTAR', walkable)
   pather:setMode("ORTHOGONAL") 

   -- Calculates the path, and its length
   return pather:getPath(player.row, player.col, tile.row, tile.col)

   -- if path then
   --    for node, count in path:nodes() do
   --      transitionPlayer(node:getX(), node:getY())
   --    end
   --  end
end

function onTileSelect( event )
  if ( event.phase == "ended" ) then
    --pathToWalk = getPath( event.target )
    walkPath(getPath( event.target ))
  end
  return true
end

function buildTile()
  local vertices = { 0,-16, -64,16, 0,48, 64,16 }
  local tile = display.newPolygon(0, 0, vertices )

  -- outline the tile and make it transparent
  tile.strokeWidth = 1
  tile:setStrokeColor( 0, 1, 1 )
  tile.alpha = .25

  return tile
end
-- draw a tile map to the screen
-- populate the tile map
function drawGrid()
   for row = 0, 5 do
      local gridRow = {}
      
      for col = 0, 5 do
        -- draw a diamond shaped tile
        --local vertices = { 0,-16, -64,16, 0,48, 64,16 }
        local tile = buildTile()
        group:insert( tile )
        
        -- set the tile's x and y coordinates
        local x = row * tileHeight
        local y = col * tileHeight

        tile.x = x - y
        -- the first part of this equation is to move the y coordinate down 32 pixels (tileHeight/2)
        -- you have to do this because the second row of tiles is .5 above the first row
        tile.y = (tileHeight/2) + ((x + y)/2) 
        tile.row = row+1
        tile.col = col+1
        tile.isEmpty = true
        tile:addEventListener("touch", onTileSelect)
        gridRow[col] = 0
      end
      -- add gridRow table to the map table
      map[row] = gridRow
   end
end

function transitionPlayer(dx,dy)
  local nx, ny = getCoordinates(dx,dy)
  transition.to(player, {time=500, x=nx, y=ny})
  --position the image
  player.row = dx
  player.col = dy
  player.x = nx
  player.y = ny
end

function drawPlayer(dx,dy)
  local x,y  = getCoordinates(dx,dy)
  player = display.newImageRect("assets/cube.png", tileWidth/2, tileHeight/1.5 )
  player:translate( x, y )
  --position the image
  player.row = dx
  player.col = dy
  player.x = x
  player.y = y
end

drawGrid()
drawPlayer(3,4)

