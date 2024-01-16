-- Consts
local WINDOW_W = 800
local WINDOW_H = 600

local DIVE_INI = 0.1

local ITER_INI = 100

-- 
local xMin, xMax, yMin, yMax = -1, 1, -1, 1
local targetCX, targetCY = 0, 0
local maxIter = ITER_INI
local diveSpeed = DIVE_INI
local showHelp = true

local mandelShader = love.graphics.newShader([[
    extern number ITER_MAX = 0;
    extern number WINDOW_W = 0;
    extern number WINDOW_H = 0;
    extern number xMin = 0;
    extern number xMax = 0;
    extern number yMin = 0;
    extern number yMax = 0;

    vec2 getCCoords(vec2 pC){
      return vec2(
                  pC.x * (xMax - xMin) / WINDOW_W + xMin, 
                  pC.y * (yMax - yMin) / WINDOW_H + yMin
                );
    }
    

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){

      vec2 CCoords = getCCoords(screen_coords);
      int iter = 0;
      vec2 n1 = vec2(0, 0);
      
      while ((iter <= ITER_MAX) && ((n1.x * n1.x + n1.y * n1.y) < 4)) {
        vec2 n = n1;
        n1.x = n.x * n.x - n.y * n.y + CCoords.x;
        n1.y = 2 * n.x * n.y + CCoords.y;

        iter = iter + 1;
      }

      float value = iter / ITER_MAX;

      if (iter < ITER_MAX){
		return vec4(
                      0,
                      0,
                      0,
                      1);

        
      }
      else {
        
		return vec4(
                      value * 0.4, 
                      value * 0.5,
                      value * 0.6,
                      1);
      }

    }
    ]])

function init()

  xMin = -2
  xMax = 1
  yMin = -1
  yMax = 1

  targetCX = -0.743643887037151
  targetCY = 0.13182590420533

  maxIter = ITER_INI 
  
  diveSpeed = DIVE_INI

  showHelp = true 
  
end


function love.load()

  love.window.setMode(WINDOW_W, WINDOW_H)
  love.window.setTitle('Mandelbrot’s fractal exploration')

  init()

end


function getCCoord(pX, pY)
  -- conversion :  pixel window coordinates  -> geometrical frame

  local c_coordX = (pX * (xMax - xMin) / WINDOW_W + xMin)
  local c_coordY = (pY * (yMax - yMin) / WINDOW_H + yMin)

  return c_coordX, c_coordY

end


function love.update(dt)

  if love.keyboard.isDown('up') then
    maxIter = maxIter + 10 
  elseif love.keyboard.isDown('down') and maxIter > 10 then
    maxIter = maxIter - 10
  end

  if love.keyboard.isDown('left') then
    diveSpeed = diveSpeed - 0.01
  elseif love.keyboard.isDown('right') then
    diveSpeed = diveSpeed + 0.01
  end

  
  if love.mouse.isDown(1) then
    local mousePosX, mousePosY = love.mouse.getPosition()
    targetCX, targetCY  = getCCoord(mousePosX, mousePosY)
  end

  xMax = xMax - math.abs(xMax - targetCX) * diveSpeed * dt
  xMin = xMin + math.abs(xMin - targetCX) * diveSpeed * dt
  yMax = yMax - math.abs(yMax - targetCY) * diveSpeed * dt
  yMin = yMin + math.abs(yMin - targetCY) * diveSpeed * dt
  
  mandelShader:send('ITER_MAX', maxIter)
  mandelShader:send('WINDOW_W', WINDOW_W)
  mandelShader:send('WINDOW_H', WINDOW_H)
  mandelShader:send('xMin', xMin)
  mandelShader:send('xMax', xMax)
  mandelShader:send('yMin', yMin)
  mandelShader:send('yMax', yMax)

end


function love.draw()
  
  love.graphics.setShader(mandelShader)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)
  love.graphics. setShader()

  if showHelp then
    love.graphics.print('Click to define a target point', 10, 10)
    love.graphics.print('Right/Left to change dive speed: '..tostring(diveSpeed), 10, 30)
    love.graphics.print('Up/Down to change max iterations: '..tostring(maxIter), 10, 50)
    love.graphics.print('r to reset, echap to quit', 10, 70)
    love.graphics.print('h to show/hide these instructions', 10, 90)
  end

end


function love.keypressed(key)

  if key == 'escape' then
    love.event.quit()
  end

  if key == 'r' then
    init()
  end

  if key == 'h' then
    showHelp = not showHelp
  end

end
