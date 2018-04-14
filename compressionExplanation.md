# **Map Compression Explanation**


## **The First Stage**

### **Firstly, what is it compressing?**

The map itself has 2 2D arrays (one for the foreground and then another for the background) where the outer arrays are for the Y axis and has 20 arrays within them. Then the inner arrays are for the X axis and has 256 items within them.

The items that are stored within the map grid are IDs which will correspond to tiles that are displayed. 


### **Run-Length Encoding**

This is the main algorithm used to do the first stage of the compression algorithim. The way it works is it will group up repeated items and also say how many times the item has been repeated. For example:

'AAABBCCCC' would then be '3A2B4C'.

### **RLE applied to the maps**

The maps will be compressed using a 2D version of RLE. So instead of just having 1 number for how many times an item has been repeated, there are 2. For example:

```lua
-- Lua uses {} for tables which can be used as both arrays/key value data structures - even at the same time.
{
    {1,1,1,1,1},
    {1,1,1,1,1},
    {1,1,1,1,1},
    {1,1,1,1}
}
```

would be 5 wide and 3 high, since the 4th layer is missing an extra 1 in the 5th index, so that would be another entry being 4 wide and 1 high. The top left x y coordinates and also the tile ID are also grouped with this entry as well.

### **And that's it for the first stage of the compression algorithm!**


## **The Final Stage**

### **Storing dynamic length numbers**

To be able to store numbers that could be as big as they needed or as little as they needed with using a suitable amount of space was needed for this compression.

The way they have been implemented is by using a control bit which will tell the translator that the number either ends there, or it takes up more bits. These control bits would also have to be placed in the number at regular predetermined intervals - the way the translator knows whether the number stops there or keeps on going. If the control bit was a 1, then it means the number keeps on going, however if it's a 0, it means that the number ends there.

Example (the control bits are placed 4 digits apart from eachother):

Let's say the initial binary number is:

10110100

Then, since the control bits are placed 4 digits apart, the representation of the number would become:

010 1 110 1 100 0 <- note the trailing 0 telling the translator that the number ends there.<br>
^ if you notice there's a leading 0, that's because I need the representation of the number to keep the same value.

Then finally, to make it into one continuous string of binary for completeness:

010111011000