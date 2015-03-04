-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
--storyboard.purgeOnSceneChange = true

-- include Corona's "physics" library
--local physics = require "physics"
--physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------
local w,h=6,6
local lx,ly=-1,-1
local currentField = {}
local selectionPath = {}
local colors = {{255,0,0}, {0,255,0}, {0,0,255}, {255,255,0}, {0,255,255}}
local errr = 10 
--local colors = {{255,0,0}, {0,255,0}}

local STATE_DONE = 0 
local STATE_MATCH = 1
local STATE_DROPPING = 2
local STATE_MOVEDOWN = 3

local function selectAnim(obj) 
        local function afterShrink(o) 
          
        end
        
        local function afterGrow(o) 
          transition.to(obj.rect, {time=200, 
            width=obj.w, height=obj.h,
            y = obj.y, x = obj.x,
            alpha=1, onComplete=afterShrink
          })
        end
        
        transition.to(obj.rect, {time=200, 
            width=obj.rect.width*1.5, height=obj.rect.height*1.5,
            y = obj.rect.y -obj.rect.height * 0.25, x = obj.rect.x -obj.rect.width * 0.25,
            alpha=1, onComplete=afterGrow
        })
end

local selLine = nil 

local timerStart = 60
local timer = timerStart
local score = 0 
local _timer 
local _score
local timerStarted = false

local combo3 = 0
local combo4 = 0 
local combo5 = 0 
local comboRec = 0 

local function cleanScene() 
  for x=1,w,1 do
    for y=1,h,1 do
      if currentField[toIdx(x,y,w,h)] then
        if currentField[toIdx(x,y,w,h)].rect then
          currentField[toIdx(x,y,w,h)].rect:removeSelf()
        end
        for k,v in pairs(currentField[toIdx(x,y,w,h)].connect) do 
         v:removeSelf()
        end
      end
    end
  end
end

function scene:createScene( event )
	local group = self.view 


local background = display.newRect( group,0, 0, screenW, screenH )
	  background.anchorX = 0
	  background.anchorY = 0
   	background:setFillColor( 1 )
   --background:toBack()
	
  	--currentField = generateField(w,h,{{255,0,0}, {0,255,0}, {0,0,255}, {255,255,0}, {0,255,255}})

  local bar = display.newRect(group, 0, 0, screenW, 50)
  bar.anchorX = 0
  bar.anchorY = 0
  bar:setFillColor(237/255,237/255,237/255)

  _timer = display.newText(group, "Time: " .. timer, 50, 22, "Amble-Light", 14)
  _timer:setFillColor(0)
  
  _score = display.newText(group, "Score: " .. score, screenW-80, 22, "Amble-Light", 14)
  _score:setFillColor(0)


local function touchObjects(event)
  if event.phase == "began" then 
    selectionPath = {} 
    local obj = findObj(currentField,event.x,event.y, errr)
    if (obj ~= nil) then 
        lx,ly = -1,-1
        table.insert(selectionPath, obj)

        selectAnim(obj)
    end
    
  elseif event.phase == "ended" then 
    if table.getn(selectionPath) > 1 then 
      removeObjects(currentField,selectionPath) 
    end 
    lx,ly = -1,-1
    
    for i=1,table.getn(selectionPath),1 do 
     local lp = selectionPath[i]
     --if lp.connect ~= nil then
       for k,v in pairs(lp.connect) do v:removeSelf() end
       lp.connect = {} 
     --end
    end 
    selectionPath = {} 
    if selLine ~= nil then 
      selLine:removeSelf()
      selLine = nil
    end 
    drawField(group,currentField,w,h) 
  elseif event.phase == "moved" then 
    if table.getn(selectionPath) > 0 then 
    
      lx,ly = event.x,event.y 
      
      local lp = selectionPath[table.getn(selectionPath)]
     -- draw from last selected to touch 
      if selLine ~= nil then 
       selLine:removeSelf()
       selLine = nil
      end 
      if lx > 5 and lx < screenW-5 and ly > 50 and ly < screenH-5 then 
        
        selLine = display.newLine(group, lp.x+lp.w/2, lp.y+lp.h/2, lx,ly)
        selLine:setStrokeColor(lp.color[1]/255,lp.color[2]/255,lp.color[3]/255)
        selLine.strokeWidth = 4
      else 
        touchObjects({phase="ended"})
      end
     
      if table.getn(selectionPath)>1 then 
       for i=1,table.getn(selectionPath)-1,1 do 
         local lp = selectionPath[i]
         local lp1 = selectionPath[i+1]
         
         local lAdd = true 
         for k,v in pairs(lp1.connect) do 
           if (math.floor(v.x) == math.floor(lp.x+lp.w/2) 
               and 
               math.floor(v.y) == math.floor(lp.y+lp.h/2)
               and 
               math.floor(v.ex) == math.floor(lp1.x+lp1.w/2)
               and 
               math.floor(v.ey) == math.floor(lp1.y+lp1.h/2)
          ) then 
        
            lAdd = false
          end
         end
           
         
         
         --if lp1.connect == nil then 
         if lAdd then 
          local l = display.newLine(group, lp.x+lp.w/2, lp.y+lp.h/2, lp1.x+lp1.w/2, lp1.y+lp1.h/2)
          l:setStrokeColor(lp.color[1]/255,lp.color[2]/255,lp.color[3]/255) -- colors are all the same so we don't care!
          l.strokeWidth = 4
          --print("feijw ",l.x2, lp.x+lp.w/2)
          l.ex,l.ey = lp1.x+lp1.w/2, lp1.y+lp1.h/2
          table.insert(lp1.connect, l)
          
          
         end 
       end
      end
     
--      else 
--        selLine.x2 = lx
--        selLine.y2 = ly
--      end
      
      local obj =  findObj(currentField,lx,ly,errr) 
      if (obj ~= nil) then 
        local lp = selectionPath[table.getn(selectionPath)]
        if (obj.color == lp.color and  -- same color? 
            (
              (lp.ix == obj.ix and math.abs(lp.iy-obj.iy)==1) or -- lays next to them horizontal/vert but not diag? 
              (math.abs(lp.ix-obj.ix)==1 and lp.iy==obj.iy)
            )
            ) then 
          
          -- do we already have this one? then we are undoing it
          local addS = true
          if table.getn(selectionPath) > 1 then
            local lp1 = selectionPath[table.getn(selectionPath)-1]
            if (lp1.ix == obj.ix and lp1.iy==obj.iy) then 
              print("removing last")
--              if lp.connect ~= nil then 
--                lp.connect:removeSelf()
--                lp.connect = nil 
--              end
              for k,v in pairs(lp.connect) do v:removeSelf() end 
              lp.connect = {}
              table.remove(selectionPath)
              addS = false
            end
          end
          
            
         if addS then 
              table.insert(selectionPath, obj)
              selectAnim(obj)
              
              checkCircular(currentField, selectionPath, true) 
          end
         
        end 
      end 
     
    end

  end 
end
  
  background:addEventListener( "touch", touchObjects )
  
--  local function tickHandler(event)
--    local background = display.newRect(group, 0, 0, screenW, screenH )
--	  background.anchorX = 0
--	  background.anchorY = 0
--   	background:setFillColor( 1 )
--    --background:toBack()
    
--    drawField(group,currentField,w,h)
    
--    -- draw the current path
--    if table.getn(selectionPath)>1 then 
--      for i=1,table.getn(selectionPath)-1,1 do 
--        local lp = selectionPath[i]
--        local lp1 = selectionPath[i+1]
--        local l = display.newLine(group, lp.x+lp.w/2, lp.y+lp.h/2, lp1.x+lp1.w/2, lp1.y+lp1.h/2)
--        l:setStrokeColor(lp.color[1]/255,lp.color[2]/255,lp.color[3]/255) -- colors are all the same so we don't care!
--        l.strokeWidth = 4
--      end
--    end
    
--    if (lx>0 and ly>0) then 
--      local lp = selectionPath[table.getn(selectionPath)]
--     -- draw from last selected to touch 
--      local l = display.newLine(group, lp.x+lp.w/2, lp.y+lp.h/2, lx,ly)
--      l:setStrokeColor(lp.color[1]/255,lp.color[2]/255,lp.color[3]/255)
--      l.strokeWidth = 4
--    end
--  end

  local sCounter = 60

  local function tickHandler(event) 
    if not timerStarted then return end
    
    if timer <= 0 then 
      timer = timerStart
      storyboard:gotoScene("done", {params={score=score}})
    end
    
    if sCounter <= 0 then 
      timer = timer - 1
      _timer.text = "Time: "..timer
      
      sCounter = 60
    end 
    sCounter = sCounter - 1
    
    
  end

  Runtime:addEventListener( "enterFrame", tickHandler )

  
end

function cmpColor(c1,c2)
  print(c1[1],c1[2],c1[3],c2[1],c2[2],c2[3])
  return c1[1]==c2[1] and c1[2] ==c2[2] and c1[3] ==c2[3]
end

function toIdx(x,y,w,h)
  return (y-1)*w+x
end

function removeRect(f,x,y,w,h) 
  if (f[toIdx(x,y,w,h)].rect ~= nil) then
    f[toIdx(x,y,w,h)].rect:removeSelf()
    f[toIdx(x,y,w,h)].rect = nil
    --score = score + 1
    --_score.text = "Score: "..score
  end
  f[toIdx(x,y,w,h)] = nil
end
-- checking circular is very simple ; you can only have one element twice if it's ciricular :) 
function checkCircular(f, selection, onlyAnim) 
  local doubles = {}
  local c = nil 
  for i=1,table.getn(selection),1 do
    if doubles[toIdx(selection[i].ix, selection[i].iy,w,h)] ~= nil then
      --print ("Detected a double ref; removing all these colors!")
      for x = 1,w,1 do 
        for y = 1,h,1 do 
           if f[toIdx(x,y,w,h)].color == c then 
             if onlyAnim then 
                selectAnim(f[toIdx(x,y,w,h)])
             else
                removeRect(f,x,y,w,h)
             end 
             --f[toIdx(x,y,w,h)] = nil
           end 
        end
      end
      return true
    end
    
    -- flag doubles
    doubles[toIdx(selection[i].ix, selection[i].iy,w,h)] = 1
    if c == nil then c = selection[i].color end
  end 
  
  return false
end

-- remove the selected object, drop down and fill up the empty spots 
function removeObjects(f, selection) 
  print ("removeObjects")
  
  -- check if we, somehow, came back to itself 
   if not checkCircular(f, selection) then  -- this one already sweeps
  
    -- sweep the objects
    for i=1,table.getn(selection),1 do 
      removeRect(f,selection[i].ix,selection[i].iy,w,h)
      --f[toIdx(selection[i].ix,selection[i].iy,w,h)] = nil 
     -- print ("sweeped   ", selection[i].ix,selection[i].iy)
    end
  
  end 
  
  
  
  
  -- drop down the columns 
  -- if we find an empty hole, fill drop all above one down 
  
  local removedCount = 0 
  for x = 1,w,1 do 
    for y = 1,h,1 do  
      
      
      if f[toIdx(x,y,w,h)] == nil then 
        removedCount = removedCount + 1
        -- empty, fill up with the first non-nil
        for _y=y-1,1,-1 do
          --f[toIdx(x,_y+1,w,h)]  = f[toIdx(x,_y,w,h)] 
          if f[toIdx(x,_y,w,h)] ~= nil then 
            
            if f[toIdx(x,_y+1,w,h)] ~= nil then
              f[toIdx(x,_y+1,w,h)].rect:removeSelf()
              f[toIdx(x,_y+1,w,h)].rect = nil 
            end
            
           -- local oy = f[toIdx(x,_y,w,h)].rect.y
            
            f[toIdx(x,_y+1,w,h)] = recalcRect(f[toIdx(x,_y,w,h)], x,_y+1,w,h)
            f[toIdx(x,_y+1,w,h)].state = STATE_MOVEDOWN
           -- f[toIdx(x,_y+1,w,h)].rect.y = oy
           -- transition.to(f[toIdx(x,_y+1,w,h)].rect, {time=1000, y=f[toIdx(x,_y+1,w,h)].rect.y})

            f[toIdx(x,_y,w,h)]  = nil 
          else 
            if f[toIdx(x,_y+1,w,h)] ~= nil then
              f[toIdx(x,_y+1,w,h)].rect:removeSelf()
            end
            f[toIdx(x,_y+1,w,h)] = nil
          end 
          
        end
      else
        -- make sure we dont double bounce
        f[toIdx(x,y,w,h)].state = STATE_DONE
      end 
    end 
  end 
  
  -- fill up the empty spots
  for x = 1,w,1 do
    for y = h,1,-1 do 
      if f[toIdx(x,y,w,h)] == nil then 
        generateRect(f,x,y,w,h,colors)
      end 
    end 
  end 
  
  if removedCount > 0 then 
    
    score = score + removedCount
    _score.text = "Score: "..score
  end
  
end

function recalcRect(o,x,y,w,h)
  local mx = 50
  local my = 150 
  local sw = 15 --math.floor((screenW-mx-(sp-1)*w)/w)
  
  local sp = (screenW-sw*w)/(w+1)
  
  local _x = (x-1)*sw + (x)*sp    
  local _y = my + (y-1)*sw + (y-1)*sp
  
  o.x = _x
  o.y = _y
  o.ix = x
  o.iy = y
  o.w = sw -- square :) 
  o.h = sw
  o.state = MATCH_DONE
  
  return o
end

function generateRect(f,x,y,w,h,cs)
  local i = math.random(table.getn(cs))
  
  local o = {}
  o.color = cs[i]
  o.connect = {}
  o = recalcRect(o,x,y,w,h)
  
  o.state = STATE_DROPPING
  --o.y = -20
 
  f[toIdx(x,y,w,h)] = o
end 

function generateField(w,h,cs)
	local f = {}
	
	for x=1,w,1 do
		for y=1,h,1 do
      generateRect(f,x,y,w,h,cs)
		end
	end
	
	return f
end

function findObj(f,xc,yc,errr)
  errr = errr or 0 
  for x=1,w,1 do 
    for y=1,h,1 do 
  
       local obj = objRect(f,x,y,w,h)
       
       if (xc >= obj.x-errr and xc <= obj.x + obj.w + errr
           and yc >= obj.y - errr and yc <= obj.y + obj.h + errr) then 
          return obj
       end
       
       
    end
  end
  return nil
end

function objRect(f,x,y,w,h)
  return f[toIdx(x,y, w,h)]
  
  
--  local mx = 50
--  local my = 100 
--  local sw = 15 --math.floor((screenW-mx-(sp-1)*w)/w)
  
--  local sp = (screenW-sw*w)/(w+1)
  
--  local _x = (x-1)*sw + (x)*sp    
--  local _y = my + (y-1)*sw + (y-1)*sp
  
--  local c = f[toIdx(x,y, w,h)]
  
--  return {_x,_y,sw,c,x,y}
end

function drawField(group,f,w,h) 
  local allDropped = 0 
  
  for x=1,w,1 do
		for y=1,h,1 do
      local obj = objRect(f,x,y,w,h)
      
      
      
      if obj ~= nil then 
        local r = obj.rect
        if r == nil then 
          --print(x,y,group)
          r = display.newRect(group, obj.x, obj.y, obj.w, obj.h)
          r.anchorX = 0
          r.anchorY = 0
          obj.rect = r 
        end 
        --r:toFront()
      

      
        --print(x,y,_x,_y,sw,c[1],c[2],c[3])
        local c = obj.color
        if c == nil then
          c = {255,255,255}
        end
        r.x = obj.x
        local oy = r.y
        r.y = obj.y
        r:setFillColor(c[1]/255,c[2]/255,c[3]/255)
        --print ("set new color ",x,y,obj.ix, obj.iy, c[1],c[2],c[3])
        
        if obj.state == STATE_MOVEDOWN then 
          obj.state = STATE_DONE
          obj.rect.y=oy
          
          local function dropComplete(o)
            
            
          end 
          
          transition.to(obj.rect, {time=500, y=obj.y, onComplete=dropComplete})
          
          
        end 
        
        if obj.state == STATE_DROPPING then
           obj.state = STATE_DONE
          obj.rect.y=obj.y-300
          
          local function dropComplete(o)
            allDropped = allDropped + 1
            if allDropped == w*h then
              timerStarted = true
            end
          end 
          
          transition.to(obj.rect, {time=1000, y=obj.y, transition=easing.outBounce, onComplete=dropComplete})
        end 
      end
      
    end
  end
  
end

-- Called immediately after scene has moved onscreen:
function scene:willEnterScene( event )
	local group = self.view
  print ("enterScene")
  
  timer = timerStart
  score = 0 
  _score.text = "Score: "..score
  _timer.text = "Time: "..timer
  timerStarted= false
	currentField = generateField(w,h,colors)
  drawField(group,currentField,w,h) 
	
	--physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	--physics.stop()
	cleanScene()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	--package.loaded[physics] = nil
	--physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "willEnterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene