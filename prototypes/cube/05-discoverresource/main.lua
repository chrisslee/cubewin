-- Hide the iPhone status bar
display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() ) 
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")
local walkable = 0 -- used by Jumper to mark obstacles
local map = {}   -- table representing each grid position
local player = {}
local pathToWalk = {}
local mode = "ORTHOGONAL"
local tileWidth = 128
local tileHeight = 64

local map = {}   -- table representing each grid position
local resources = {}  -- table tracking the markers we are putting on the grid
local tiles = {} -- table to store our tiles

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

function checkPlayerOnResource( event )
  if player.walking == true then
    print('player on the move')
  elseif player.onResource == true then
    print('getting resource units')
  end
end

function getCoordinates(dx,dy)
  local x = (display.contentWidth * 0.5 + ((dx - dy) * tileHeight)) 
  local y = (((dx + dy)/2) * tileHeight) - (tileHeight/2)
  return x,y
end

function walkPath()
  player.idx = 2
  player.myPath = {}
  player.walking = false

  for node, count in player.pathNodes do
    local xPos, yPos = node:getPos()
    player.myPath[#player.myPath+1] = {x=xPos, y=yPos}
  end
  if #player.myPath > 1 then
    player.walking = true
    local function nextStep(obj)
      if player.idx < #player.myPath+1 then
        local cx,cy = getCoordinates(player.myPath[player.idx].x,player.myPath[player.idx].y)
        player.row = player.myPath[player.idx].x
        player.col = player.myPath[player.idx].y
        transition.to(player, {time=500, x=cx, y=cy, onComplete=nextStep})
      else 
        player.walking = false
      end
      player.idx = player.idx + 1
    end
    nextStep()
  end
end

function getPathNodes( tile )
   -- create a Jumper Grid object by passing in our map table
   local grid = Grid(map)

   local pather = Pathfinder(grid, 'ASTAR', walkable)
   pather:setMode(mode) 

   -- Calculates the path, and its length
   local path = pather:getPath(player.row, player.col, tile.row, tile.col)
   return path:nodes()
end

function onTileSelect( event )
  if ( event.phase == "ended" ) then
    --pathToWalk = getPath( event.target )
    player.pathNodes = {}
    local pathNodes = getPathNodes( event.target )
    if (pathNodes) then
      player.pathNodes = pathNodes
      walkPath()
      if (event.target.hasResource == true) then
        print('tile has resource')
        player.onResource = true
      else
        player.onResource = false
      end
    else
      print("nodes was nil")
    end
  end
  return true
end

function placeResourceOnTile( dx, dy )
  print('called placeReourceOnTile and tiles count is ' .. #tiles)
  if #tiles > 0 then
    for i=1,#tiles do
      print('looking at tile ' .. tiles[i].row .. ',' .. tiles[i].col)
      if tiles[i].row == dx and tiles[i].col == dy then
        tiles[i].hasResource = true
        tiles[i].isEmpty = false
        print('placed resource on tile ' .. tiles[i].row .. ',' .. tiles[i].col )
        break --end the loop because we found a conflict
      end
    end
  end 
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

function drawGrid()
   for row = 0, 5 do
      local gridRow = {}
      
      for col = 0, 5 do
        -- draw a diamond shaped tile
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
        tile.hasResource = false
        tile:addEventListener("touch", onTileSelect)
        
        --resources[#resources+1] = {x=pTile.x, y=pTile.y}
        tiles[#tiles+1] = tile
        print(tiles[#tiles].row)

        -- telling the pathfinding if the grid loc is traversable 
        gridRow[col] = 0 -- zero means you can walk here
      end
      -- add gridRow table to the map table
      map[row] = gridRow
   end
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
  gamePiece:insert(player)
end

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
      placeResourceOnTile(pTile.x, pTile.y)
    end
  end
end


drawGrid()
buildResources()
drawPlayer(3,4)

Runtime:addEventListener( "enterFrame", checkPlayerOnResource )