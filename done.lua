-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	storyboard.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local score = nil 

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- display a background image
	local background = display.newRect( group, 0, 0,display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor(1)
  
  local gameOver = display.newText(group,"Game Over", 200,200, "Amble-Light", 49)
  gameOver.x = display.contentWidth * 0.5
	gameOver.y = 100
  gameOver:setFillColor(0)
  
  local yourScore = display.newText(group,"Score:", 200,200, "Amble-Light", 28)
  yourScore.x = display.contentWidth * 0.5
	yourScore.y = 250
  yourScore:setFillColor(0)
  
  score = display.newText(group, "400", 200,200, "Amble-Light", 24)
  score.x = display.contentWidth * 0.5
	score.y = 300
  score:setFillColor(0)
  
    local function handleClick(event) 
      if event.phase == "ended" then
        
        storyboard.gotoScene("level1", "fade", 500)
      
      end
    end
  
     playBtn = widget.newButton
   {
      left = 40,
      top = display.contentHeight-100,
      label = "Play again",
      labelAlign = "center",
      font = native.systemFontBold,
      fontSize = 18,
      width = 240,
      height = 34,
      labelColor = { default = {0,0,0}, over = {0,0,0} },
      onEvent = handleClick
   }
   group:insert(playBtn)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
  if event.params and event.params.score then 
    
    score.text = event.params.score
  end
  
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene