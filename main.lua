function print_debug(text)
  if DEBUG then
    print(text)
  end
end

function print_centered(text, y_offset)
  if not y_offset then
    y_offset = -1 * font_size
  end
  love.graphics.printf(text, 0, (win_size/2)+y_offset, win_size, 'center')
end

function game_won()
  return string.len(WORD_CHECK) > 0 and WORD_CHECK == WORD
end

function game_lost()
  return not game_won() and TRIES >= MAX_TRIES
end

function wx(word, solved, check)
  word = string.upper(word)

  local w = {}
  local i, chr
  for i = 1, string.len(word), 1 do
    chr = string.sub(word, i, i)
    if solved[chr] then
      w[#w+1] = chr
    else
      w[#w+1] = "_"
    end
  end
  local delim = check and "" or " "
  word = table.concat(w, delim)
  return word
end

function add_solved(chr)
  chr = string.upper(chr)
  if string.match(WORD, chr) then
    CORRECT[chr] = 1
    WORD_CHECK = wx(WORD, CORRECT, true)
  else
    TRIES = TRIES + 1
  end
end

--- Split a string using a pattern.
-- @param str The string to search in
-- @param pat The pattern to search with
-- @see http://lua-users.org/wiki/SplitJoin
function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = '(.-)' .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= '' then
      t[#t+1] = cap
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    t[#t+1] = cap
  end
  return t
end

function love.load()
  DEBUG = false
  font_size = 40
  imgw = 300
  imgh = 300
  btnw = 40
  btnh = 50
  btnm = 2
  local word_min_length = 3

  ALPHA = "abcdefghijklmnopqrstuvwxyz"
  WORD_CHECK = ""
  CORRECT = {}

  local rnd = love.math.random(1, string.len(ALPHA))
  local chr = string.upper(string.sub(ALPHA, rnd, rnd))
  local filename = "assets/eowl/" .. chr .. " Words.txt"
  local words = love.filesystem.read(filename)
  words = split(words, "\n")
  WORD = ""

  while string.len(WORD) < word_min_length do
    rnd = love.math.random(1, #words)
    WORD = string.upper(words[rnd]:gsub("^%s*(.-)%s*$", "%1"))
  end

  TRIES = 0
  MAX_TRIES = 11

  COLOR_BG = {50, 50, 50, 255}
  COLOR_BTN = {100, 100, 100, 255}
  COLOR_TXT = {30, 30, 30, 255}
  COLOR_SOLVED = {150, 200, 150, 255}

  local button_rows = 2
  local len = string.len(ALPHA)/button_rows
  win_size = (len*btnw) + (len-1)*btnm
  local win_flags = {resizable = false}
  local font = love.graphics.newFont("assets/ConsolaMono.ttf", font_size)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(COLOR_BG)
  love.window.setMode(win_size, win_size, win_flags)

  main_img = {}
  local i
  for i = 1, MAX_TRIES + 1, 1 do
    filename = i < 11 and "0" .. (i-1) or (i-1)
    main_img[i] = love.graphics.newImage("assets/" .. filename .. ".jpg")
  end
  
  main_pos_x = (win_size/2) - (imgw/2)
  main_pos_y = 30

  buttons = {}
  local x, y, x2, y2, i, j, idx

  for i = 1, len, 1 do
    for j = 1, button_rows, 1 do
      idx = i + (j-1)*len
      x = ((i-1)*btnw) + (i-1)*btnm
      y = (win_size - (-j * (btnh+btnm)) - (3*btnh+btnm))
      buttons[idx] = {
        value = string.upper(string.sub(ALPHA, idx, idx)),
        x = x,
        y = y,
        x2 = x+btnw,
        y2 = y+btnh,
      }
    end
  end
end

function love.draw()
  if game_lost() then
    print_centered("You lost!\n The word was:\n" .. WORD)
  elseif game_won() then
    local percent = ((MAX_TRIES - TRIES) / MAX_TRIES) * 100
    print_centered("You won!\n Score: " .. string.format("%.0f", percent) .."%")
  else
    love.graphics.draw(main_img[TRIES+1], main_pos_x, main_pos_y)
    print_centered(wx(WORD, CORRECT), 2*font_size)

    local r, g, b, a, v
    r, g, b, a = love.graphics.getColor()
    for _, v in pairs(buttons) do
      if CORRECT[v["value"]] then
        love.graphics.setColor(COLOR_SOLVED)
      else
        love.graphics.setColor(COLOR_BTN)
      end
      love.graphics.rectangle("fill", v["x"], v["y"], btnw, btnh)
      love.graphics.setColor(COLOR_TXT)
      love.graphics.print(v["value"], v["x"]+6, v["y"]-3)
    end
    love.graphics.setColor(r, g, b, a)
  end
end

function love.mousepressed(x, y, button)
  if button == "l" then
    local v
    for _, v in pairs(buttons) do
      if x >= v["x"] and x <= v["x2"] and y >= v["y"] and y <= v["y2"] then
        print_debug("click: " .. v["value"])
        add_solved(v["value"])
      end
    end
  end
end