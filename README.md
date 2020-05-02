# lovr-window
A window module for LÖVR.

# Usage
### If you use lovr 0.13.0 or older you need to update [glfw3.dll](https://www.glfw.org/download.html) to 3.3 version

First of all you need to add some new parameters in your `lovr.conf()`
>
Just replace all old window related code to this:
```lua
t.window.title = "LÖVR"
t.window.icon = nil
t.window.fullscreen = false 
t.window.fullscreentype = "exclusive" 
t.window.width = 1080
t.window.height = 600
t.window.minwidth = 100
t.window.minheight = 180
t.window.x = nil
t.window.y = nil
t.window.centered = false
t.window.topmost = false
t.window.borderless = false
t.window.resizable = true -- Manual window resizing with mouse doesn't call lovr.resize() callback right now
t.window.opacity = 1
t.window.vsync = 0
t.window.framelimit = 60 -- Frame limit for timestep in lovr.run()
t.window.msaa = 0

w = t.window
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

function lovr.resize(width, height)
	print(width, height)
end
```

# API
###### Functions
- `window.close()` *Closes the window.*
- `window.getMode()` *Gets the display mode and properties of the window.*
- `window.setMode(width, height[, flags])` *Sets the display mode and properties of the window.*
- `window.requestAttention()` *Causes the window to request the attention of the user if it is not in the foreground.*
- `window.setOpacity(value)` *Sets opacity value of the Window.*
- `window.getOpacity()` *Returns opacity value of the Window.*
- `window.setPosition(x, y)` *Sets the position of the window on the screen.*
- `window.getPosition()` *Gets the position of the window on the screen.*
- `window.focus()` *Sets focus on the window.*
- `window.maximize()` *Makes the window as large as possible.*
- `window.minimize()` *Minimizes the window to the system's task bar / dock.*
- `window.restore()` *Restores the size and position of the window if it was minimized or maximized.*
- `window.setTitle(title)` *Sets the window title.*
- `window.getTitle()` *Gets the window title.*
- `window.visible(state)` *Makes the window visible / invisible.*
- `window.isVisible()` *Checks if the game window is visible.*
- `window.setFullscreen(fullscreen[, fstype])` *Enters or exits fullscreen.*
- `window.getFullscreen()` *Gets whether the window is fullscreen.*
###### Callbacks
- `love.resize(w, h)` *Called when the window is resized.*

# Documentation
### Functions
- `window.close()` *Closes the window.*
	###### Returns `nothing`
---
- `window.getMode()` *Gets the display mode and properties of the window.*
	###### Returns
	- **`number`**` width`
	- **`number`**` height`
	- **`table`**` flags` The flags table with the options:
		- **`string`**`title`
		- **`number`**`x`
			> X position of the window on screen.
			> 
		- **`number`**`y`
			> Y position of the window on screen.
			> 
		- **`number`**`minwidth`
			> The minimum width of the window, if it's resizable.
			> 
		- **`number`**`minheight`
			> The minimum height of the window, if it's resizable.
			>
		- **`boolean`**`fullscreen`
			> `true` if window is in fullscreen mode, `false` otherwise.
			> 
		- **`string`**`fullscreentype`
			> For default fullscreen mode value is `"exclusive"`, for borderless fullscreen windowed mode is `"desktop"` and `nil` if window in windowed mode.
			> 
		- **`boolean`**`resizable` 
			> `true` if the window is resizable in windowed mode, `false` otherwise.
			> 
		- **`boolean`**`borderless`
			> `true` if the window is borderless in windowed mode, `false` otherwise.
			> 
		- **`boolean`**`centered`
			> `true` if the window is centered in windowed mode, `false` otherwise.
			> 
		- **`boolean`**`topmost`
			> `true` if the window is topmost in windowed mode, `false` otherwise.
			> 
		- **`number`**`opacity`
			> Window's opacity value between `0` and `1`
		- **`number`**`msaa`
			> The number of antialiasing samples used.
			
---
- `window.setMode(width, height, flags)` *Sets the display mode and properties of the window.*
	> 
	###### Arguments
	- **`number`**` width`
	- **`number`**` height`
	- **`table`**` flags` The flags table with the options:
		>
		- **`string`**`title`
			> New title for the window.
			> 
		- **`number`**`x`
			> `nil` if window is centered.
			> 
		- **`number`**`y`
			> `nil` if window is centered.
			> 
		- **`number`**`minwidth`
			> The minimum width of the window, if it's resizable.
			> 
		- **`number`**`minheight`
			> The minimum height of the window, if it's resizable.
			>
		- **`boolean`**`fullscreen`
			> Should the window be in fullscreen mode. `true` for fullscreen or `false` for windowed mode.
			> 
		- **`string`**`fullscreentype`
			> Use `"desktop"` for borderless fullscreen windowed mode or `"exclusive"` for default fullscreen mode.
			> 
		- **`boolean`**`resizable`
			> `true` if the window should be resizable, `false` otherwise. For windowed mode only.
			> 
		- **`boolean`**`resizable` 
			> `true` if the window is resizable, `false` otherwise. For windowed mode only.
			> 
		- **`boolean`**`borderless`
			> `true` if the window is borderless, `false` otherwise. For windowed mode only.
			> 
		- **`boolean`**`centered`
			> `true` if the window is centered, `false` otherwise. For windowed mode only.
			> 
		- **`boolean`**`topmost`
			> `true` if the window is topmost, `false` otherwise. For windowed mode only.
			> 
		- **`number`**`opacity`
			> **`number`** value between `0` and `1`
			>
		- **`number`**`msaa`
			> **`number`** The number of antialiasing samples to use
---
- `window.requestAttention()` *Causes the window to request the attention of the user if it is not in the foreground.*
	> In Windows the taskbar icon will flash, and in OS X the dock icon will bounce.
	> 
	###### Returns `nothing`
---
- `window.setOpacity(value)` *Sets opacity value of the Window.*
	###### Arguments
	- **`number`**`opacity`
		> **`number`** value between `0` and `1`
		> 
---
- `window.getOpacity()` *Returns opacity value of the Window.*
	###### Returns
	- **`number`**`opacity`
---
- `window.setPosition(x, y)` *Sets the position of the window on the screen.*
	> This function sets the paramter of the window `centered` to `false`.
	> 
	###### Arguments
	- **`number`**`x`
		> X position of the window on screen.
		> 
	- **`number`**`y`
		> Y position of the window on screen.
		> 
---
- `window.getPosition()` *Gets the position of the window on the screen.*
	###### Returns
	- **`number`**`x`
		> X position of the window on screen.
		> 
	- **`number`**`y`
		> Y position of the window on screen.
		> 
---
- `window.focus()` *Sets focus on the window.*
	###### Returns `nothing`
---
- `window.maximize()` *Makes the window as large as possible.*
	###### Returns `nothing`
---
- `window.minimize()` *Minimizes the window to the system's task bar / dock.*
	###### Returns `nothing`
---
- `window.restore()` *Restores the size and position of the window if it was minimized or maximized.*
	###### Returns `nothing`
---
- `window.setTitle(title)` *Sets the window title.*
	###### Arguments
	- **`string`**`title`
		> New title for the window.
		> 
---
- `window.getTitle()` *Gets the window title.*
	###### Returns
	- **`string`**`title`
		> Title of the window.
		> 
---
- `window.visible(state)` *Makes the window visible / invisible.*
	###### Arguments
	- **`boolean`**`state`
		> `true` if the window is visible or `false` if not.
		> 
---
- `window.isVisible()` *Checks if the game window is visible.*
	###### Returns
	- **`boolean`**`visible`
		> `true` if the window is visible or `false` if not.
		> 
---
- `window.setFullscreen(fullscreen[, fstype])` *Enters or exits fullscreen.*
	###### Arguments
	- **`boolean`**`fullscreen`
		> `true` for fullscreen, or `false` for windowed mode.
		> 
	- **`string`**`fullscreentype`
		> Use `"desktop"` for borderless fullscreen windowed mode or `"exclusive"` for default fullscreen mode.
		> 
---
- `window.getFullscreen()` *Gets whether the window is fullscreen.*
	###### Returns
	- **`boolean`**`fullscreen`
		> `true` if the window is in fullscreen mode, `false` otherwise.
		> 
	- **`string`**`fullscreentype`
		> `"desktop"` if window in borderless fullscreen windowed mode or `"exclusive"` if window is in default fullscreen mode. For windowed mode fullscreen type is `nil`.
		> 

### Callbacks
- `love.resize(width, height)` *Called when the window is resized.*
	> Right now because of missing functionality the callback will only be called when the window is resized programmatically.
	>
	###### Arguments
	- **`number`**`width`
		> New width of the window after resize.
		> 
	- **`number`**`height`
		> New height of the window after resize.
		> 
	###### Example
	```lua
	function love.resize(width, height)
		print(("Window resized to width: %d and height: %d."):format(width, height))
	end
	```
