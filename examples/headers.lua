local sys = require("system")
local t = require("terminal")

local linesWritten = 0
local appName = "The best terminal ever"
local currentCursorY = 2
local currentCursorX = 2

-- header 
local function drawHeader()
  local rows, cols = sys.termsize()
  local currentTime = os.date("%H:%M:%S")
  
  local cursorText = string.format("Pos: %d,%d", currentCursorY, currentCursorX)
  
  t.textpush{
    fg = "white",
    bg = "blue",
    brightness = "bright",
  }
  
  t.cursor_set(1, 1)
  t.output.write(string.rep(" ", cols))
  
  t.cursor_set(1, 2)
  t.output.write(appName)
  
  local clockPos = math.floor(cols / 4)
  t.cursor_set(1, clockPos)
  t.output.write(currentTime)
  
  local cursorPos = math.floor(cols / 2) + 5
  t.cursor_set(1, cursorPos)
  t.output.write(cursorText)
  
  local colorText = "Color: "
  t.cursor_set(1, cols - #colorText - 1)
  t.output.write(colorText)
  
  t.textpop()
end

-- footer 
local function drawFooter()
  local rows, cols = sys.termsize()
  local lineText = "Lines: " .. linesWritten
  local text = "Thank you for using MyTerminal!"
  

  t.textpush{
    fg = "white",
    bg = "blue",
    brightness = "bright",
  }
  
  t.cursor_set(rows, 1)
  t.output.write(string.rep(" ", cols))
  
  t.cursor_set(rows, 2)
  t.output.write(lineText)
  
  t.cursor_set(rows, cols - #text - 1)
  t.output.write(text)
  
  t.textpop()
end

-- writing area
local function updateWritingArea()
  local rows, cols = sys.termsize()
  
  t.textset{
    fg = "green",
    bg = "black",
    brightness = "normal",
  }
  
  for i = 2, rows - 1 do
    t.cursor_set(i, 1)
    t.output.write(string.rep(" ", cols))
  end

  t.cursor_set(2, 2)
  currentCursorY = 2
  currentCursorX = 2
end

local function updateCursorPosition(y, x)
  currentCursorY = y
  currentCursorX = x
  t.cursor_set(y, x)
end

-- input area
local function handleInput()
  local rows, cols = sys.termsize()
  local writingHeight = rows - 2 
  
  while true do
    drawHeader()
    drawFooter()
    
    t.cursor_set(currentCursorY, currentCursorX)
    
    local key = t.input.readansi(1)  
    
    if key then
      if key == "f10" or key == "\27" then
        break
      elseif key == "\r" or key == "\n" then
        linesWritten = linesWritten + 1
        drawFooter()
        
        if currentCursorY < rows - 1 then
          updateCursorPosition(currentCursorY + 1, 2)
        else
          updateCursorPosition(currentCursorY, 2)
          t.output.write(string.rep(" ", cols))
        end
      elseif key == "\08" or key == "\127" then
        if currentCursorX > 2 then
          updateCursorPosition(currentCursorY, currentCursorX - 1)
          t.output.write(" ")
          updateCursorPosition(currentCursorY, currentCursorX)
        elseif currentCursorY > 2 then
          updateCursorPosition(currentCursorY - 1, cols - 2)
        end
      elseif key == "[A" and currentCursorY > 2 then

        updateCursorPosition(currentCursorY - 1, currentCursorX)
      elseif key == "[B" and currentCursorY < rows - 1 then

        updateCursorPosition(currentCursorY + 1, currentCursorX)
      elseif key == "[C" and currentCursorX < cols then

        updateCursorPosition(currentCursorY, currentCursorX + 1)
      elseif key == "[D" and currentCursorX > 2 then
        updateCursorPosition(currentCursorY, currentCursorX - 1)
      else
        t.output.write(key)
        updateCursorPosition(currentCursorY, currentCursorX + 1)
      end
    end
    
    t.output.flush()
  end
end


local function runTerminal()
  t.initialize{
    displaybackup = true,
    filehandle = io.stdout,
  }
  t.clear()
  
  drawHeader()
  updateWritingArea()
  drawFooter()
  
  handleInput()
  
  t.shutdown()
  print("Thank you for using MyTerminal! You wrote " .. linesWritten .. " lines.")
end

runTerminal()