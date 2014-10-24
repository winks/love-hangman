function print_debug(text)
  if DEBUG then
    print(text)
  end
end

function print_centered(text)
  love.graphics.printf(text, 0, (win_size/2)-(font_size), win_size, 'center')
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

function love.load()
  DEBUG = false
  font_size = 40
  imgw = 75
  imgh = 75
  btnw = 20
  btnh = 35
  btnm = 2

  WORD = "HANGMANASDFG"
  WORD_CHECK = ""
  CORRECT = {}
  ALPHA = "abcdefghijklmnopqrstuvwxyz"

  TRIES = 0
  MAX_TRIES = 11

  win_size = (string.len(ALPHA)*btnw) + ((string.len(ALPHA)-1)*btnm)
  local win_flags = {resizable = false}
  local font = love.graphics.newFont("assets/ConsolaMono.ttf", font_size)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(50, 50, 50)
  love.window.setMode(win_size, win_size, win_flags)

  main_img = {}
  main_img[1] = love.graphics.newImage("assets/back.jpg")
  local i, filename
  for i = 2, MAX_TRIES + 1, 1 do
    filename = i < 11 and "0" .. (i-1) or (i-1)
    main_img[i] = love.graphics.newImage("assets/" .. filename .. ".jpg")
  end
  
  main_pos_x = (win_size/2) - (imgw/2)
  main_pos_y = 100

  buttons = {}
  local x, y, x2, y2
  for i = 1, string.len(ALPHA), 1 do
    x = ((i-1)*btnw) + (i-1)*btnm
    y = (win_size - btnh)
    buttons[i] = {
      value = string.upper(string.sub(ALPHA, i, i)),
      x = x,
      y = y,
      x2 = x+btnw,
      y2 = y+btnh,
    }
  end
end

function love.draw()
  if game_lost() then
    print_centered("You lost!")
  elseif game_won() then
    print_centered("You won!")
  else
    love.graphics.draw(main_img[TRIES+1], main_pos_x, main_pos_y)
    print_centered(wx(WORD, CORRECT))

    local r, g, b, a, v
    r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(70, 50, 50)
    for _, v in pairs(buttons) do
      love.graphics.rectangle("fill", v["x"], v["y"], btnw, btnh)
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