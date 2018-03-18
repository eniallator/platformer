# **Map Compression Explanation**

## **Firstly, what is it compressing?**

The map itself has 2 2D arrays (one for the foreground and then another for the background) where the outer arrays are for the Y axis and has 20 arrays within them. Then the inner arrays are for the X axis and has 256 items within them.

The items that are stored within the map grid are IDs which will correspond to tiles that are displayed. 


## **Run-Length Encoding**

This is the main algorithm used to do the first stage of the compression algorithim. The way it works is it will group up repeated items and also say how many times the item has been repeated. For example:

'AAABBCCCC' would then be '3A2B4C'.

## **RLE applied to the maps**

The maps will be compressed using a 2D version of RLE. So instead of just having 1 number for how many times an item has been repeated, there are 2. For example:

```lua
-- Lua uses {} for tables which are arrays/key value data structures in 1 data structure.
{
    {1,1,1,1,1},
    {1,1,1,1,1},
    {1,1,1,1,1},
    {1,1,1,1}
}
```

would be 5 wide and 3 high, since the 4th layer is missing an extra 1 in the 5th index, so that would be another entry being 4 wide and 1 high. The top left x y coordinates and also the tile ID are also grouped with this entry as well.

## **And that's it for the first stage of the compression algorithm!**
