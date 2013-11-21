local Map = require 'map'
local GUI = require 'Quickie'

local m = nil
local tile = nil
local fileInput = { text = 'Filename' }

local function setTerrain(terrain)
  if not tile then return end

  tile.terrain = terrain
end

function love.load()
  m = Map(3, 3)
end

function love.update(dt)
  GUI.group.push{
    grow = 'down',
    pos = {
      love.graphics.getWidth() - GUI.group.default.size[1],
      0,
    },
  }

  if tile then
    if GUI.Button{ text = 'Plain' } then
      setTerrain('Plain')
    end

    if GUI.Button{ text = 'Forest' } then
      setTerrain('Forest')
    end

    if GUI.Button{ text = 'Mountain' } then
      setTerrain('Mountain')
    end

    if GUI.Button{ text = 'Amplifier' } then
      setTerrain('Amplifier')
    end

    if GUI.Checkbox{ checked = tile.connections[1], text = 'North' } then
      tile.connections[1] = not tile.connections[1]
    end

    if GUI.Checkbox{ checked = tile.connections[2], text = 'East' } then
      tile.connections[2] = not tile.connections[2]
    end

    if GUI.Checkbox{ checked = tile.connections[3], text = 'South' } then
      tile.connections[3] = not tile.connections[3]
    end

    if GUI.Checkbox{ checked = tile.connections[4], text = 'West' } then
      tile.connections[4] = not tile.connections[4]
    end
  end

  GUI.group.pop()

  GUI.group.push{
    grow = 'right',
    pos = {
      0,
      love.graphics.getHeight() - GUI.group.default.size[2],
    },
  }

  GUI.Input{ info = fileInput }
  
  if GUI.Button{ text = 'Load' } then
    m:load(fileInput.text)
  end

  if GUI.Button{ text = 'Save' } then
    m:save(fileInput.text)
  end

  GUI.group.pop()
end

function love.draw()
  love.graphics.setColor(255, 255, 255)

  GUI.core.draw()

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
end

function love.keypressed(key, code)
  GUI.keyboard.pressed(key, code)

  if key == 'escape' then
    love.event.quit()
  end
end

function love.mousepressed(x, y, button)
  if m:withinMap(x, y) then
    tile = m:getTile(x, y)
  end
end
