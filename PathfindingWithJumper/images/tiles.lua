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
            y=50,
            width=50,
            height=50,

        },
        {
            -- grass@2x
            x=82,
            y=96,
            width=32,
            height=32,

        },
        {
            -- helo_blue03@2x
            x=82,
            y=64,
            width=32,
            height=32,

        },
        {
            -- mountain@2x
            x=50,
            y=96,
            width=32,
            height=32,

        },
        {
            -- move@2x
            x=0,
            y=0,
            width=50,
            height=50,

        },
        {
            -- soldier_blue01@2x
            x=50,
            y=64,
            width=32,
            height=32,

        },
        {
            -- soldier_red01@2x
            x=82,
            y=32,
            width=32,
            height=32,

        },
        {
            -- tank2_red03@2x
            x=50,
            y=32,
            width=32,
            height=32,

        },
        {
            -- trees@2x
            x=82,
            y=0,
            width=32,
            height=32,

        },
        {
            -- water_13@2x
            x=50,
            y=0,
            width=32,
            height=32,

        },
    },
    
    sheetContentWidth = 128,
    sheetContentHeight = 128
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
