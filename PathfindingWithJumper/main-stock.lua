-- Project: Pathfinding with Jumper
-- Description: Using the Jumper library to get from point A to point B
--
-- Version: 1.0
-- Managed with http://OutlawGameTools.com
-- Tutorial code from: http://MasteringCoronaSDK.com
-- Copyright 2013 J. A. Whye. All Rights Reserved.

display.setStatusBar(display.HiddenStatusBar)

local widget = require("widget")

-- most commonly used screen coordinates
-- thanks to crawlSpaceLib for initial set
centerX = display.contentCenterX
centerY = display.contentCenterY
screenLeft = display.screenOriginX
screenWidth = display.contentWidth - screenLeft * 2
screenRight = screenLeft + screenWidth
screenTop = display.screenOriginY
screenHeight = display.contentHeight - screenTop * 2
screenBottom = screenTop + screenHeight

local pathFilter = false

local numSquaresChosen = {}

-- Jumper setup
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")

local map = {
	{5, 5, 5, 5, 5, 5, 5, 5, 5, 5},
	{5, 0, 0, 0, 0, 0, 0, 5, 0, 5},
	{5, 0, 5, 0, 5, 5, 0, 0, 0, 5},
	{5, 0, 5, 0, 0, 5, 5, 5, 0, 5},
	{5, 0, 5, 5, 5, 5, 0, 0, 0, 5},
	{5, 0, 0, 0, 0, 0, 0, 5, 0, 5},
	{5, 0, 5, 5, 0, 5, 5, 5, 0, 5},
	{5, 0, 5, 0, 0, 0, 5, 0, 0, 5},
	{5, 0, 5, 0, 0, 0, 0, 0, 0, 5},
	{5, 5, 5, 5, 5, 5, 5, 5, 5, 5}
}

local walkable = 0

local grid = Grid(map)

-- create a rounded rectangle on the screen.
local function doSquare(x,y,c,s)
	local sz = s or 32
	local radius = 8
	if sz == 32 then radius = 0 end
	local square = display.newRoundedRect(0, 0, sz, sz, radius)
	--square.strokeWidth = 1
	square:setStrokeColor(172, 172, 172)
	square:setFillColor(c[1], c[2], c[3])
	square.x = (x * 32) - 16
	square.y = (y * 32) - 16
	return square
end

local function goMapping(startPos, endPos)
	local sx,sy = startPos.x, startPos.y
	local ex,ey = endPos.x, endPos.y

	local pather = Pathfinder(grid, "ASTAR", walkable) -- "DIJKSTRA","JPS","THETASTAR","BFS","DFS","ASTAR"
	pather:setMode("ORTHOGONAL") -- "ORTHOGONAL"  "DIAGONAL"

	local path = pather:getPath(sx,sy, ex,ey, false)
	if pathFilter then
		path:filter()
	end
	if path then
		print(('Path found! Length: %.2f'):format(path:getLength()))
		local myPath = {}
		for node, count in path:nodes() do
			local x, y = node:getX(), node:getY()
			print(('Step: %d - x: %d - y: %d'):format(count, x, y))
			doSquare(x, y, {200,0,0},25)
			myPath[#myPath+1] = {x=x, y=y}
		end
		--print_r(myPath)
	else
	    print(('Path from [%d,%d] to [%d,%d] was : not found!'):format(sx,sy,ex,ey))
	end  
end

local function drawMap()
	local function selectSquare(event)
		if #numSquaresChosen < 2 then
			local gridPos = event.target.gridPos
			numSquaresChosen[#numSquaresChosen+1] = {x=gridPos.x, y=gridPos.y}
			doSquare(gridPos.x, gridPos.y, {255,255,255}, 30)
			if #numSquaresChosen == 2 then
				goMapping(numSquaresChosen[1], numSquaresChosen[2])
			end
		end
		return true
	end
	
	local colors = {  {0, 0, 0}, {112, 251, 255} }
	for x = 1, #map[1] do
		for y = 1, #map do
			local color = colors[map[y][x]+1] or {67, 149, 255}
			local gridSquare = doSquare(x,y,color, 32)
			gridSquare.gridPos = {x=x, y=y}
			gridSquare:addEventListener("tap", selectSquare)
		end
	end
end

local function resetMap(event)
	numSquaresChosen = {}
	drawMap()
	return true
end

local function togglePathFilter(event)
	pathFilter = not pathFilter 
	return true 
end
		
local function setUpDisplay()

	local bg = display.newRect(screenLeft, screenTop, screenWidth, screenHeight)
	bg:setFillColor(217, 210, 255)
	
	local onOff = widget.newSwitch ({ 
		style="checkbox", 
		initialSwitchState=pathFilter, 
		onPress=togglePathFilter 
		})
	onOff.x = screenRight-30
	onOff.y = screenTop + 20

	local txt = display.newText( "Filter:", 0, 0, "Helvetica", 18 )
	txt:setTextColor(0,0,0)
	txt.x = onOff.x - 45
	txt.y = onOff.y
	
	local resetButton = widget.newButton ({ 
		width = 100, 
		label = "Reset", 
		onRelease = resetMap,
	})
	resetButton.x = screenRight - 80
	resetButton.y = screenBottom - 40
	
	drawMap()

end

setUpDisplay()	
