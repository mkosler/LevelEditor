local Map = require 'map'
local GUI = require 'Quickie'

local m = nil
local tile = nil
local hasError = false
local err = ''
local fileInput = { text = 'Filename' }

local function moveSelector(tile, key)
  local row, column = 0, 0

  if tile then row, column = tile.row, tile.column end

  if     key == 'up'    and row > 0 then
    return row - 1, column
  elseif key == 'down'  and row < m.rows - 1 then
    return row + 1, column
  elseif key == 'left'  and column > 0 then
    return row, column - 1
  elseif key == 'right' and column < m.columns - 1 then
    return row, column + 1
  end

  return row, column
end

local function changeConnections(key)
  if key == 'w' then
    tile.connections[1] = not tile.connections[1]
  elseif key == 'd' then
    tile.connections[2] = not tile.connections[2]
  elseif key == 's' then
    tile.connections[3] = not tile.connections[3]
  elseif key == 'a' then
    tile.connections[4] = not tile.connections[4]
  end
end

local function setTerrain(terrain)
  if not tile then return end

  tile.terrain = terrain
end

local function changeTerrain(key)
  if key == '1' then
    setTerrain('Plain')
  elseif key == '2' then
    setTerrain('Forest')
  elseif key == '3' then
    setTerrain('Mountain')
  elseif key == '4' then
    setTerrain('Amplifier')
  end
end

function love.load()
  m = Map(15, 30)
end

function love.update(dt)
  GUI.group.push{
    grow = 'left',
    pos = {
      love.graphics.getWidth() * 3 / 4,
      love.graphics.getHeight() - (GUI.group.default.size[2] * 2),
    },
  }

  if tile then
    -- Direction selection
    GUI.group.push{ grow = 'down' }

    GUI.group.push{ grow = 'right' }

    if GUI.Checkbox{ checked = tile.connections[1], text = 'North' } then
      tile.connections[1] = not tile.connections[1]
    end

    if GUI.Checkbox{ checked = tile.connections[2], text = 'East' } then
      tile.connections[2] = not tile.connections[2]
    end

    GUI.group.pop()

    GUI.group.push{ grow = 'right' }

    if GUI.Checkbox{ checked = tile.connections[3], text = 'South' } then
      tile.connections[3] = not tile.connections[3]
    end

    if GUI.Checkbox{ checked = tile.connections[4], text = 'West' } then
      tile.connections[4] = not tile.connections[4]
    end

    GUI.group.pop()

    GUI.group.pop()

    -- Terrain selection
    GUI.group.push{ grow = 'down' }

    GUI.group.push{ grow = 'right' }

    if GUI.Button{ text = 'Plain' } then
      setTerrain('Plain')
    end

    if GUI.Button{ text = 'Forest' } then
      setTerrain('Forest')
    end

    GUI.group.pop()

    GUI.group.push{ grow = 'right' }

    if GUI.Button{ text = 'Mountain' } then
      setTerrain('Mountain')
    end

    if GUI.Button{ text = 'Amplifier' } then
      setTerrain('Amplifier')
    end

    GUI.group.pop()

    GUI.group.pop()
  end

  GUI.group.pop()

  GUI.group.push{
    grow = 'down',
    pos = {
      0,
      love.graphics.getHeight() - (GUI.group.default.size[2] * 2),
    },
  }

  GUI.Input{
    info = fileInput,
    size = {
      GUI.group.default.size[1] * 2 + GUI.group.default.spacing
    },
  }

  GUI.group.push{ grow = 'right' }
  
  if GUI.Button{ text = 'Load' } then
    hasError, err = m:load(fileInput.text)
    hasError = not hasError
  end

  if GUI.Button{ text = 'Save' } then
    hasError, err = m:save(fileInput.text)
    hasError = not hasError
  end

  GUI.group.pop()

  GUI.group.pop()

  if hasError then
    local font = love.graphics.getFont()
    local fw = font:getWidth(err)

    if GUI.Button{
      text = err,
      size = { fw },
      pos = {
        love.graphics.getWidth() / 2 - (fw / 2),
        love.graphics.getHeight() / 2 - (GUI.group.default.size[2] / 2),
      },
    } then
      hasError = false
    end
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)

  m:draw()

  if tile then
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle(
      'line',
      tile.x,
      tile.y,
      m.tilewidth,
      m.tileheight)
  end

  GUI.core.draw()
end

function love.keypressed(key, code)
  GUI.keyboard.pressed(key, code)

  local r, c = moveSelector(tile, key)
  tile = m:getTileByMatrix(r, c)

  if tile then
    changeConnections(key)
    changeTerrain(key)
  end

  if key == 'escape' then
    love.event.quit()
  end
end

function love.mousepressed(x, y, button)
  if hasError then return end

  if m:withinMap(x, y) then
    tile = m:getTile(x, y)
  end
end
