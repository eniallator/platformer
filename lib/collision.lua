local collision = {}

collision.detectPlayer = function(x,y)
  for i=1,#mapGrid do
    for j=1,#mapGrid[i] do
      if type(mapGrid[i][j]) == "table" and blocks[mapGrid[i][j].block].solid and (j -1) *blockSize < x + player.w and x <= j *blockSize and (i -1) *blockSize < y + player.h and y <= i *blockSize then

        return true
      end
    end
  end

  return false
end

return collision
