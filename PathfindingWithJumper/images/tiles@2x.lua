--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:9ef151a3ea4875f1f6c7ccd7fd4325ae$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- attackcrosshair@2x
            x=0,
            y=100,
            width=100,
            height=100,

        },
        {
            -- grass@2x
            x=164,
            y=192,
            width=64,
            height=64,

        },
        {
            -- helo_blue03@2x
            x=164,
            y=128,
            width=64,
            height=64,

        },
        {
            -- mountain@2x
            x=100,
            y=192,
            width=64,
            height=64,

        },
        {
            -- move@2x
            x=0,
            y=0,
            width=100,
            height=100,

        },
        {
            -- soldier_blue01@2x
            x=100,
            y=128,
            width=64,
            height=64,

        },
        {
            -- soldier_red01@2x
            x=164,
            y=64,
            width=64,
            height=64,

        },
        {
            -- tank2_red03@2x
            x=100,
            y=64,
            width=64,
            height=64,

        },
        {
            -- trees@2x
            x=164,
            y=0,
            width=64,
            height=64,

        },
        {
            -- water_13@2x
            x=100,
            y=0,
            width=64,
            height=64,

        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["attackcrosshair"] = 1,
    ["grass"] = 2,
    ["helo_blue"] = 3,
    ["mountain"] = 4,
    ["move"] = 5,
    ["soldier_blue"] = 6,
    ["soldier_red"] = 7,
    ["tank2_red"] = 8,
    ["trees"] = 9,
    ["water"] = 10,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
