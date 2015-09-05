-- Project: Move Tank
-- Description: Using Jumper to Move a Tank
--
-- Version: 1.0
-- Managed with http://OutlawGameTools.com
-- Tutorial code from: http://MasteringCoronaSDK.com
-- Artwork courtesy Vicki Wenderlich http://vickiwenderlich.com
-- Copyright 2013 Three Ring Ranch. All Rights Reserved.

display.setStatusBar(display.HiddenStatusBar)

local widget = require("widget")

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

local drawer
local map = {}
local mapStartPos = {}
local mapEndPos = {}
local tank
local tankPresent = false
local mode = "ORTHOGONAL"

--==============================================================
-- Jumper setup
--==============================================================

local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")

--==============================================================
-- utilty functions
--==============================================================

-- pass in pixel coords and get back the grid coords
-- as a table: {x=n, y=n}
local function gridXYFromPixelXY(x,y)
	local pos = {}
	pos.x = math.floor((x)/32) + 1
	if pos.x < 1 then pos.x = 1 end
	pos.y = math.floor((y)/32) + 1
	if pos.y < 1 then pos.y = 1 end
	--print("pos.x/y", pos.x, pos.y, x, y)
	return pos
end

-- pass in grid coords and get back pixel pos for 
-- center of that square as a table: {x=n, y=n}
local function pixelXYFromGridXY(x,y)
	local pos = {}
	pos.x = math.floor((x)*32) -16
	pos.y = math.floor((y)*32) -16
	return pos
end

-- console output of the walkable map you create
local function printMap()
	for row = 1, 10 do
		local oneRow = {}
		local rowStr = "{"
		for col = 1, 15 do
			oneRow[#oneRow+1] = map[row][col]
			rowStr = rowStr .. tostring(map[row][col])
			if col < 15 then
				rowStr = rowStr .. ","
			end
		end
		rowStr = rowStr .. "},"
		print(rowStr)
	end
end

--==============================================================
-- move the tank from point to point, following the
-- path returned from jumper.
--==============================================================

local function followPath()
	tank.idx = 2
	tank.myPath = {}
	for node, count in tank.pathNodes do
		local xPos, yPos = node:getPos()
		print(('Step: %d - x: %d, y: %d'):format(count, xPos, yPos))
		tank.myPath[#tank.myPath+1] = {x=xPos, y=yPos}
	end
	if #tank.myPath > 1 then
		local function nextStep(obj)
			if tank.idx < #tank.myPath+1 then
				local pos = pixelXYFromGridXY(tank.myPath[tank.idx].x,tank.myPath[tank.idx].y)
				transition.to(tank, {time=500, x=pos.x, y=pos.y, onComplete=nextStep})
			else
				mapStartPos = tank.myPath[tank.idx-1]
			end
			tank.idx = tank.idx + 1
		end
		nextStep()
	end
end

--==============================================================
-- the jumper code that finds the best path from 
-- startPos to endPos.
--==============================================================

local function goMapping(startPos, endPos)
	local sx,sy = startPos.x, startPos.y
	local ex,ey = endPos.x, endPos.y
	local walkable = 0
	
	local grid = Grid(map)
	local pather = Pathfinder(grid, 'JPS', walkable) -- "DIJKSTRA","JPS","THETASTAR","BFS","DFS","ASTAR"
	pather:setMode(mode) -- 'ORTHOGONAL'  'DIAGONAL'
	
	local path = pather:getPath(sx,sy, ex,ey)
	if path then
		if mode == "DIAGONAL" then
			path:fill()
		end
		tank.pathNodes = path:nodes()
		followPath()
		print(('Path found! Length: %.2f'):format(path:getLength()))
	else
	    print(('Path from [%d,%d] to [%d,%d] was : not found!'):format(sx,sy,ex,ey))
	end  
end

--==============================================================
-- make the grass squares. add tap event to
-- each so we can see the grid coords for
-- that square.
--==============================================================

local function makeGround()
	local function grassTouched(event)
		local tile = event.target
		print("{x=" .. tile.gridPos.x .. ", y=" .. tile.gridPos.y .. "}")
	end
	for row = 1, 10 do
		local oneRow = {}
		for col = 1, 15 do
			local grass = display.newImageRect("tiles/grass.png", 32, 32)
			grass.width = 31 -- for testing only
			grass.height = 31 -- for testing only
			grass.x = (col * 32) - 15.5
			grass.y = (row * 32) - 15.5
			grass.gridPos = {x=col, y=row}
			grass.xyPos = {x=grass.x, y=grass.y}
			grass:addEventListener("tap", grassTouched)
			oneRow[col] = 0
		end
		map[row] = oneRow
	end
end

--==============================================================
-- drop-down drawer at the top that holds the objects we
-- can drag onto the grid. touch to toggle open/close.
--==============================================================

local function makeDrawer()
	local sheetInfo = require("images.tiles")
	local myImageSheet = graphics.newImageSheet( "images/tiles.png", sheetInfo:getSheet() )

	--==============================================================
	-- existing object is touched and dragged on the grid
	--==============================================================
	local function tileDrag(event)
		local obj = event.target
		if event.phase == "began" then
			display.getCurrentStage():setFocus(obj)
			obj.startMoveX = obj.x
			obj.startMoveY = obj.y
			obj.isFocus = true
			map[obj.gridPos.y][obj.gridPos.x] = 0
		elseif obj.isFocus then
			if event.phase == "moved" then
				obj.x = (event.x - event.xStart) + obj.startMoveX
				obj.y = (event.y - event.yStart) + obj.startMoveY
			elseif event.phase == "ended" or event.phase == "cancelled" then
				display.getCurrentStage():setFocus(nil)
				local pos = gridXYFromPixelXY(event.target.x, event.target.y)
				local pixX = pos.x * 32 - 16
				local pixY = pos.y * 32 - 16
				obj.x = pixX 
				obj.y = pixY
				obj.gridPos = pos -- save the grid X/Y location
				printMap()
				print(event.target.name)
				if event.target.name == "tank2_red" then
					mapStartPos = pos
					tankPresent = true
				elseif event.target.name == "attackcrosshair" then
					mapEndPos = pos
					if tankPresent then
						goMapping(mapStartPos, mapEndPos)
					end
				else
					map[pos.y][pos.x] = 1
				end
			end
		end
		return true
	end
	--==============================================================
	-- an object is chosen from the drawer, then cloned.
	--==============================================================
	local function tilePicked(event)
		if event.phase == "began"  then
			local t = display.newImageRect( myImageSheet , sheetInfo:getFrameIndex(event.target.name), 32, 32)
			t.x = event.x
			t.y = event.y
			t.startMoveX = t.x
			t.startMoveY = t.y
			t.isFocus = true
			t.name = event.target.name
			t:addEventListener( "touch", tileDrag )
			display.getCurrentStage():setFocus( t )
			if event.target.name == "attackcrosshair" or event.target.name == "tank2_red" then
				event.target.alpha = 0 -- only allow choosing one of each of those
			end
			if t.name == "tank2_red" then tank = t end
		end
		return true
	end
	--==============================================================
	-- open and close the drawer
	--==============================================================
	local function toggleDrawer(event)
		if drawer.y > screenTop then
			transition.to(drawer, {time=300, y=drawer.y-35}) -- go up
		else
			drawer:toFront()
			transition.to(drawer, {time=300, y=drawer.y+35}) -- go down
		end
		return true
	end
	--==============================================================
	-- create the drawer and show available objects.
	--==============================================================
	drawer = display.newGroup ( )
	local drawerTiles = {"mountain","trees","water","soldier_blue","soldier_red","attackcrosshair","tank2_red"}
	local drawerBG = display.newRect( screenLeft, screenTop, screenWidth, 40 )
	drawer:insert(drawerBG)
	drawer:addEventListener("tap", toggleDrawer)
	drawerBG.x = centerX
	drawerBG.y = screenTop+20
	for x = 1, #drawerTiles do
		local tile = display.newImageRect( myImageSheet , sheetInfo:getFrameIndex(drawerTiles[x]), 32, 32)
		tile:scale(.8, .8)
		tile.x = screenLeft + (x * 40)
		tile.y = drawerBG.y-1
		tile.name = drawerTiles[x]
		tile:addEventListener("touch", tilePicked)
		drawer:insert(tile)
	end
	drawer:setReferencePoint(display.CenterReferencePoint)
	toggleDrawer()
end

--==============================================================
-- show background, create grid (ground) and drop-down drawer.
--==============================================================

local function setupDisplay()
	local bg = display.newRect(screenLeft, screenTop, screenWidth, screenHeight)
	bg:setFillColor(206, 26, 0)
	
	local function toggleMode(event)
		if event.target.isOn then
			mode = "DIAGONAL"
		else
			mode = "ORTHOGONAL"
		end
		return true 
	end
	
	makeGround()
	makeDrawer()

	local modeSwitch = widget.newSwitch ({ 
		style="checkbox", 
		initialSwitchState=false, 
		onPress=toggleMode })
	modeSwitch.x = screenRight - 25
	modeSwitch.y = screenBottom - 20
	
end

setupDisplay()
	
