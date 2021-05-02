# lovr-window
A window module for LÖVR.

# Usage
### This library requires [glfw3.dll](https://www.glfw.org/download.html) 3.4+ version

First of all you need to add some new parameters in your `lovr.conf()`
>
Just append this parameters next to window related code:
```lua
-- additional window parameters
t.window.fullscreentype = "desktop"	-- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
t.window.x = nil			-- The x-coordinate of the window's position in the specified display (number)
t.window.y = nil			-- The y-coordinate of the window's position in the specified display (number)
t.window.minwidth = 1			-- Minimum window width if the window is resizable (number)
t.window.minheight = 1			-- Minimum window height if the window is resizable (number)
t.window.display = 1			-- Index of the monitor to show the window in (number)
t.window.centered = false		-- Align window on the center of the monitor (boolean)
t.window.topmost = false		-- Show window on top (boolean)
t.window.borderless = false		-- Remove all border visuals from the window (boolean)
t.window.resizable = false		-- Let the window be user-resizable (boolean)
t.window.opacity = 1			-- Window opacity value (number)

conf = t.window
```
After setting up your config function you can require window module and use it

```lua
lovr.window = require 'lovr-window'

function lovr.load()
	-- print all window parameters into console
	local mode = lovr.window.getMode()
	for k,v in pairs(mode) do
		print(k, v)
	end
	
	-- sets window resolution, opacity, msaa and title
	lovr.window.setMode(1280, 720, {title = "Hello, Window!", resizable = true, opacity = 0.5, msaa = 4})
end

function lovr.maximized( v, w,h )
	print(v and "maximized" or "restored")
end

function lovr.dragdrop( paths )
	for i=1, #paths do
		--prints all file/directory paths dropped on the window
		print(paths[i])
	end
end

function lovr.windowmoved( x,y )
	print("Current window position:", x,y)
end

```

# API
###### Functions
| Function | Description |
|-|-|
| [window.getDisplayDimensions( index )](#getDisplayDimensions) | Gets the width and height of the desktop |
| [window.getDisplayCount()](#getDisplayCount) | Gets the number of connected monitors |
| [window.getDisplayName( index )](#getDisplayName) | Gets the name of a display |
| [window.getFullscreen()](#getFullscreen) | Gets whether the window is fullscreen |
| [window.getIcon()](#getIcon) | Gets the window icon |
| [window.getMode()](#getMode) | Gets the display mode and properties of the window |
| [window.getOpacity()](#getOpacity) | Returns opacity value of the Window |
| [window.getPosition()](#getPosition) | Gets the position of the window on the screen |
| [window.getTitle()](#getTitle) | Gets the window title |
| [window.isVisible()](#isVisible) | Checks if the game window is visible |
| [window.maximize()](#maximize) | Makes the window as large as possible |
| [window.minimize()](#minimize) | Minimizes the window to the system's task bar / dock |
| [window.requestAttention()](#requestAttention) | Causes the window to request the attention of the user if it is not in the foreground |
| [window.restore()](#restore) | Restores the size and position of the window if it was minimized or maximized |
| [window.setFullscreen(fullscreen[, fstype])](#setFullscreen) | Enters or exits fullscreen |
| [window.setIcon( source )](#setIcon) | Sets the window icon |
| [window.setMode( width, height[, flags]) ](#setMode) | Sets the display mode and properties of the window |
| [window.setOpacity( value )](#setOpacity) | Sets opacity value of the Window |
| [window.setPosition( x,y )](#setPosition) | Sets the position of the window on the screen |
| [window.setTitle( title )](#setTitle) | Sets the window title |
| [window.focus()](#focus) | Sets focus on the window |
| [window.visible( state )](#visible) | Makes the window visible / invisible |

###### Callbacks
| Callback | Description |
|-|-|
[love.maximized( state, w,h )](#maximized) | Called when the window is maximized/restored |
[love.windowmoved( x,y )](#windowmoved) | Callback function triggered when the window is moved |
[love.dragdrop( paths )](#dragdrop) | Callback function triggered when a file/directory is dragged and dropped onto the window |


# Documentation
## getDisplayDimensions()
###### Function
``` lua
width, height = window.getDisplayDimensions( index )
```

###### Arguments
**[`number`](Home#lua-types)** index

###### Returns
**[`number`](#number)** width
**[`number`](#number)** height





## getDisplayCount()
###### Function
``` lua
count = window.getDisplayCount()
```

###### Arguments
None.

###### Returns
**[`number`](#number)** count





## getDisplayName()
###### Function
``` lua
name = window.getDisplayName( index )
```

###### Arguments
**[`number`](Home#lua-types)** index

###### Returns
**[`string`](#string)** name





## getFullscreen()
###### Function
``` lua
fullscreen, fullscreentype = window.getFullscreen()
```

###### Arguments
None.

###### Returns
**[`boolean`](#boolean)** fullscreen
**[`string`](#string)** fullscreentype





## getIcon()
###### Function
``` lua
icon = window.getIcon()
```

###### Arguments
None.

###### Returns
**[`Image`](https://lovr.org/docs/v0.15.0/Image)** icon





## getMode()
###### Function
``` lua
width, height, flags = window.getMode()
```

###### Arguments
None.

###### Returns
**[`number`](#number)** width
**[`number`](#number)** height
**[`table`](#table)** flags
- **[`number`](#number)** x
- **[`number`](#number)** y
- **[`number`](#number)** minwidth
- **[`number`](#number)** minheight
- **[`boolean`](#boolean)** fullscreen
- **[`string`](#string)** fullscreentype
- **[`number`](#number)** vsync
- **[`number`](#number)** msaa
- **[`boolean`](#boolean)** resizable
- **[`boolean`](#boolean)** borderless
- **[`boolean`](#boolean)** centered
- **[`number`](#number)** display
