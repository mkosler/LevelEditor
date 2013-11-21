local Map = {}
Map.__index = Map

----------------------------------------------------------
-- Requires ----------------------------------------------
----------------------------------------------------------

local bit32 = require 'numberlua'.bit32
local lg = love.graphics

----------------------------------------------------------
-- Private -----------------------------------------------
----------------------------------------------------------

local TERRAIN = {
  P = 'Plains',
  F = 'Forest',
  M = 'Mountain',
  A = 'Amplifier',
}

local function createEmptyTiles(rows, columns, tilewidth, tileheight)
  local tiles = {}

  for x = 0, columns - 1 do
    tiles[x] = {}

    for y = 0, rows - 1 do
      tiles[x][y] = {
        x = x * tilewidth,
        y = y * tileheight,
        terrain = 'Plains',
        connections = {},
      }
    end
  end

  return tiles
end

local function getConnectionTable(cvalue)
  return {
    bit32.band(cvalue, 8) == 8,
    bit32.band(cvalue, 4) == 4,
    bit32.band(cvalue, 2) == 2,
    bit32.band(cvalue, 1) == 1,
  }
end

local function getConnectionValue(ctable)
  local cvalue = 0

  if ctable[1] then
    cvalue = cvalue + 8
  end

  if ctable[2] then
    cvalue = cvalue + 4
  end

  if ctable[3] then
    cvalue = cvalue + 2
  end

  if ctable[4] then
    cvalue = cvalue + 1
  end

  return cvalue
end

local function testFilename(filename)
  local match = filename:match('.smf')
  if match then
    return true
  else
    return false, 'Invalid filename (missing .smf extension)'
  end
end

----------------------------------------------------------
-- Public ------------------------------------------------
----------------------------------------------------------

function Map:new(rows, columns, x, y, tilewidth, tileheight)
  local o = {}

  o.x = x or 0
  o.y = y or 0

  o.tilewidth = tilewidth or 25
  o.tileheight = tileheight or o.tilewidth

  o.rows = rows
  o.columns = columns

  o._tiles = createEmptyTiles(o.rows, o.columns, o.tilewidth, o.tileheight)

  return setmetatable(o, Map)
end

function Map:draw()
  for x = 0, self.columns - 1 do
    for y = 0, self.rows - 1 do
      local tile = self._tiles[x][y]

      if tile.connections[1] then
        lg.line(tile.x + (self.tilewidth / 2), tile.y + (self.tileheight / 2),
                tile.x + (self.tilewidth / 2), tile.y)
      end

      if tile.connections[2] then
        lg.line(tile.x + (self.tilewidth / 2), tile.y + (self.tileheight / 2),
                tile.x + self.tilewidth, tile.y + (self.tileheight / 2))
      end

      if tile.connections[3] then
        lg.line(tile.x + (self.tilewidth / 2), tile.y + (self.tileheight / 2),
                tile.x + (self.tilewidth / 2), tile.y + self.tileheight)
      end

      if tile.connections[4] then
        lg.line(tile.x + (self.tilewidth / 2), tile.y + (self.tileheight / 2),
                tile.x, tile.y + (self.tileheight / 2))
      end

      lg.rectangle(
        'line',
        tile.x + (self.tilewidth / 4),
        tile.y + (self.tileheight / 4),
        self.tilewidth / 2,
        self.tileheight / 2)

      lg.setColor(0, 0, 0)
      lg.rectangle(
        'fill',
        tile.x + (self.tilewidth / 4),
        tile.y + (self.tileheight / 4),
        self.tilewidth / 2,
        self.tileheight / 2)

      lg.setColor(255, 255, 255)
      lg.print(
        tile.terrain:sub(1, 1),
        tile.x + (self.tilewidth / 3),
        tile.y + (self.tileheight / 3))
    end
  end
end

function Map:withinMap(x, y)
  local pw = self.columns * self.tilewidth
  local ph = self.rows * self.tileheight

  return self.x <= x and x <= pw and
         self.y <= y and y <= ph
end

function Map:getTile(x, y)
  local nx = math.floor(x / self.tilewidth)
  local ny = math.floor(y / self.tileheight)

  if nx < 0 or nx >= self.columns then return end
  if ny < 0 or ny >= self.rows then return end

  return self._tiles[nx][ny]
end

function Map:load(filename)
  assert(type(filename) == 'string', 'Filename must be a string')

  local b, err = testFilename(filename)
  if not b then return false, err end

  local f = io.open(filename)
  if not f then
    return false, 'File not found'
  end

  local contents = f:read('*a')

  local i = 0
  for t, c in contents:gmatch('(%a)(%x)') do
    c = tonumber(c, 16)

    local x, y = i % self.columns, math.floor(i / self.columns)

    self._tiles[x][y].terrain = TERRAIN[string.upper(t)]
    self._tiles[x][y].connections = getConnectionTable(c)

    i = i + 1
  end

  io.close(f)

  return true
end

function Map:save(filename)
  assert(type(filename) == 'string', 'Filename must be a string')

  local suffix = filename:match('.smf')

  if not suffix then return false, 'Invalid filename' end

  local f = io.open(filename, 'w')

  f:write(self:__tostring())

  f:close()

  return true
end

function Map:__tostring()
  local s = ''

  for y = 0, self.rows - 1 do
    for x = 0, self.columns - 1 do
      local tile = self._tiles[x][y]

      local t = string.upper(tile.terrain:sub(1, 1))
      local c = getConnectionValue(tile.connections)

      s = s .. string.format('%s%X ', t, c)
    end

    s = s .. '\n'
  end

  return s
end

return setmetatable(Map, { __call = Map.new })
