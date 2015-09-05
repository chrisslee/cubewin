-- Project: Move Tank
-- Description: Using Jumper to Make Flames follow a Vase
--
-- Version: 1.0
-- Managed with http://OutlawGameTools.com
-- Tutorial code from: http://MasteringCoronaSDK.com
-- Artwork courtesy Dangerous Dave Returns
-- Copyright 2013 Three Ring Ranch. All Rights Reserved.

display.setStatusBar(display.HiddenStatusBar)

--==============================================================
-- variables and forward references
--==============================================================

-- most commonly used screen coordinates
-- thanks to crawlSpaceLib for initial set
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.contentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.contentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local mRandom = math.random
local mFloor = math.floor

local sqWidth = 32
local sqHeight = 32

local vase
local goMapping

local map = {
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
	{1,0,0,0,1,0,0,0,1,1,1,0,0,0,1},
	{1,0,0,1,0,0,0,0,1,0,0,0,0,0,1},
	{1,0,0,1,0,0,1,0,1,0,0,0,0,0,1},
	{1,0,1,0,0,1,0,0,1,0,0,0,0,0,1},
	{1,0,0,0,1,0,0,1,0,0,0,0,0,0,1},
	{1,0,0,0,1,0,0,0,0,0,1,0,0,0,1},
	{1,0,0,0,1,0,0,0,0,0,0,0,0,0,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	}


--==============================================================
-- Jumper setup
--==============================================================

local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")

local walkable = 0
	
local grid = Grid(map)
local pather = Pathfinder(grid, 'JPS', walkable)
local mode = "DIAGONAL" -- DIAGONAL  ORTHOGONAL
pather:setMode(mode)

--==============================================================
-- utilty functions
--==============================================================

-- pass in pixel coords and get back the grid coords
-- as a table: {x=n, y=n}
local function gridXYFromPixelXY(x,y)
	local pos = {}
	pos.x = mFloor((x)/sqWidth) + 1
	pos.y = mFloor((y)/sqHeight) + 1
	return pos
end

-- pass in grid coords and get back pixel pos for 
-- center of that square as a table: {x=n, y=n}
local function pixelXYFromGridXY(x,y)
	local pos = {}
	pos.x = mFloor((x)*sqWidth) - sqWidth/2
	pos.y = mFloor((y)*sqHeight) - sqHeight/2
	return pos
end

--==============================================================
-- move the obj from point to point, following the
-- path returned from jumper.
--==============================================================

local function followPath(obj)
	if obj.idx < #obj.myPath + 1 then
		-- if goal has moved, find the new path
		if obj.targetX ~= vase.xGrid or obj.targetY ~= vase.yGrid then
			obj.targetX = vase.xGrid
			obj.targetY = vase.yGrid
			goMapping(obj, {x=obj.myPath[obj.idx].x, y=obj.myPath[obj.idx].y}, {x=vase.xGrid, y=vase.yGrid})
			obj.idx = 1
		end
		local pos = pixelXYFromGridXY(obj.myPath[obj.idx].x, obj.myPath[obj.idx].y)
		transition.to(obj, {time=obj.speed, x=pos.x, y=pos.y, onComplete=followPath})
		obj.idx = obj.idx + 1
	else
		display.remove( obj )
	end
end

--==============================================================
-- the jumper code that finds the best path
-- for obj from startPos to endPos.
--==============================================================

function goMapping(obj, startPos, endPos)
	local sx,sy = startPos.x, startPos.y
	local ex,ey = endPos.x, endPos.y
	
	local path = pather:getPath(sx,sy, ex,ey)
	if path then
		if mode == "DIAGONAL" then
			path:fill()
		end
		obj.targetX = vase.xGrid
		obj.targetY = vase.yGrid
		local pNodes = path:nodes()
		obj.myPath = {}
		for node, count in pNodes do
			local xPos, yPos = node:getPos()
			obj.myPath[#obj.myPath+1] = {x=xPos, y=yPos}
		end
		obj.idx = 2 -- start with the next step
	else
	    print(('Path from [%d,%d] to [%d,%d] was : not found!'):format(sx,sy,ex,ey))
	end  
end

--==============================================================

local function drawMap()
	for row = 1, #map do
		for col = 1, #map[1] do
			if map[row][col] == 1 then
				local mountain = display.newImageRect("images/ddstone.png", 32, 32)
				mountain.x = (col * 32) - 16
				mountain.y = (row * 32) - 16
			end
		end
	end
end

--==============================================================

local function makeBadGuy()
	local xGrid = 2
	local yGrid = mRandom(2,9)
	local badGuy = display.newImage("images/ddflame.png")--display.newRect( 0, 0, 6, 18 )
	--badGuy:setFillColor(255, 9, 133)
	local pos = pixelXYFromGridXY(xGrid,yGrid)
	badGuy.x = pos.x
	badGuy.y = pos.y
	badGuy.speed = mRandom(300, 500)
	goMapping(badGuy, {x=xGrid, y=yGrid}, {x=vase.xGrid, y=vase.yGrid})
	if #badGuy.myPath > 0 then
		followPath(badGuy)
	end
end
	
local function makeVase(xGrid, yGrid)
	vase = display.newImage("images/ddvase.png")
	local pos = pixelXYFromGridXY(xGrid, yGrid)
	vase.x = pos.x
	vase.y = pos.y
	vase.xGrid = xGrid
	vase.yGrid = yGrid
end

local function resetVase(event)
	local pos = gridXYFromPixelXY(event.x, event.y)
	if not vase then
		makeVase(pos.x, pos.y)
	end
	vase.xGrid = pos.x
	vase.yGrid = pos.y
	pos = pixelXYFromGridXY(pos.x, pos.y)
	transition.to ( vase, {time=200, x=pos.x, y=pos.y} )
	timer.performWithDelay ( 500, makeBadGuy, 5 )
end

local function setupDisplay()
	local bg = display.newRect(screenLeft, screenTop, #map[1]*32, #map*32)
	bg.x = centerX
	bg.y = centerY
	bg:setFillColor(0, 0, 0)
	bg:addEventListener ( "tap", resetVase )
	drawMap()
end

setupDisplay()
