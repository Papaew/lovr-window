local ffi = require 'ffi'
local C = ffi.os == 'Windows' and ffi.load('glfw3') or ffi.C
local C_str = ffi.string

ffi.cdef [[
	enum {
		GLFW_RESIZABLE = 0x00020003,
		GLFW_VISIBLE = 0x00020004,
		GLFW_DECORATED = 0x00020005,
		GLFW_FLOATING = 0x00020007
	};
	typedef struct {
		int width;
		int height;
		unsigned char* pixels;
	} GLFWimage;
	typedef struct GLFWvidmode {
		int width;
		int height;
		int refreshRate;
	} GLFWvidmode;

	typedef struct GLFWwindow GLFWwindow;
	GLFWwindow* glfwGetCurrentContext(void);
	
	typedef struct GLFWmonitor GLFWmonitor;
	GLFWmonitor** glfwGetMonitors(int *count);
	GLFWmonitor* glfwGetWindowMonitor(GLFWwindow* window);
	GLFWmonitor* glfwGetPrimaryMonitor(void);

	void glfwGetMonitorPos(GLFWmonitor* monitor, int *xpos, int *ypos);
	const char* glfwGetMonitorName(GLFWmonitor* monitor);
	const GLFWvidmode* glfwGetVideoMode(GLFWmonitor* monitor);
	void glfwSetWindowMonitor(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);
	void glfwGetMonitorWorkarea(GLFWmonitor *monitor, int *xpos, int *ypos, int *width, int *height);
	
	// icon
	void glfwSetWindowIcon(GLFWwindow* window, int count, const GLFWimage *images);
	
	// attributes
	void glfwSetWindowAttrib(GLFWwindow* window, int attrib, int value); //+
	int glfwGetWindowAttrib(GLFWwindow* window, int attrib); //+
	
	// size & limits
	void glfwSetWindowSize(GLFWwindow* window, int width, int height); //-
	void glfwGetWindowSize(GLFWwindow* window, int *width, int *height); //-
	void glfwSetWindowSizeLimits(GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight); //-
	
	// position
	void glfwSetWindowPos(GLFWwindow* window, int xpos, int ypos);
	void glfwGetWindowPos(GLFWwindow* window, int *xpos, int *ypos);
	
	// minimize maximize restore
	void glfwMaximizeWindow(GLFWwindow* window);
	void glfwIconifyWindow(GLFWwindow *window);
	void glfwRestoreWindow(GLFWwindow *window);
	
	// title
	void glfwSetWindowTitle(GLFWwindow* window, const char* title);
	
	// visible
	void glfwShowWindow(GLFWwindow* window);
	void glfwHideWindow(GLFWwindow* window);
	
	// focus
	void glfwFocusWindow(GLFWwindow* window);
	
	// attention
	void glfwRequestWindowAttention(GLFWwindow* window);
	
	// opacity
	void glfwSetWindowOpacity(GLFWwindow* window, float opacity);
	float glfwGetWindowOpacity(GLFWwindow* window);

	// callbacks
	typedef void(*GLFWwindowsizefun) (GLFWwindow*, int, int); // size changed
	GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow* window, GLFWwindowsizefun callback );

	typedef void(*GLFWwindowmaximizefun) (GLFWwindow*, int); // maximize
	GLFWwindowmaximizefun glfwSetWindowMaximizeCallback(GLFWwindow* window, GLFWwindowmaximizefun callback);

	typedef void(*GLFWwindowposfun) (GLFWwindow*, int, int); // position changed
	GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow* window, GLFWwindowposfun callback);

	typedef void(* GLFWdropfun) (GLFWwindow*, int, const char *[]);
	GLFWdropfun glfwSetDropCallback(GLFWwindow* window, GLFWdropfun callback);	
	
]]
local W = C.glfwGetCurrentContext()
local window = {}
local __monitors
---------------------------------------------------------------------------------------------------------------
local __params = { -- default parameters list
	title = 'LÖVR',
	icon = nil,
	fullscreen = false,
	fullscreentype = "desktop",
	width = 1080,
	height = 600,
	minwidth = 320,
	minheight = 240,
	x = nil,
	y = nil,
	display = 1,
	centered = false,
	topmost = false,
	borderless = false,
	resizable = false,
	opacity = 1,
	vsync = 1,
	msaa = 0
}
if conf then
	for k,v in pairs(conf) do
		__params[k] = v
	end

	if type(__params.icon) == 'string' then
		__params.icon = lovr.data.newImage(__params.icon, false)
	end
	conf = nil
end

---------------------------------------------------------------------------------------------------------------
function window.getDisplayCount()
	local count = ffi.new('int[1]')
	__monitors = C.glfwGetMonitors(count)
	return count[0]
end

local function check_monitor( index, throwerr )
	if type(index) ~= 'number' then
		if throwerr then
			error('Bad argument #1: number expected got ' .. type(index), 3)
		else
			return false
		end
	end

	local dcnt = window.getDisplayCount()
	if index < 1 or index > dcnt then
		if throwerr then
			error('Invalid display index: ' .. tostring(index), 3)
		else
			return false
		end
	end

	return true
end

function window.getDisplayName( index )
	check_monitor( index, true )
	return C_str(C.glfwGetMonitorName( __monitors[index-1] ))
end

function window.getDisplayDimensions( index )
	check_monitor( index, true )
	local screenmode = C.glfwGetVideoMode( __monitors[index-1] )
	return screenmode.width, screenmode.height
end

---------------------------------------------------------------------------------------------------------------

function window.setIcon( source )
	if not source then
		C.glfwSetWindowIcon(W, 0, nil)
		__params.icon = nil
		return
	end

	if type(source) == 'string' then
		source = lovr.data.newImage(source, false)
	elseif tostring(source) ~= 'Image' then
		error('Bad argument #1 to setIcon (Image expected)', 2)
	end
	__params.icon = source

	local icon = ffi.new('GLFWimage', source:getWidth(), source:getHeight(), source:getBlob():getPointer())
	C.glfwSetWindowIcon(W, 1, icon)
end

function window.getIcon()
	return tostring(__params.icon) == 'Image' and __params.icon or nil
end

---------------------------------------------------------------------------------------------------------------

function window.setOpacity( value )
	value = math.max(0, math.min(value, 1))
	C.glfwSetWindowOpacity(W, value)
end

function window.getOpacity()
	return C.glfwGetWindowOpacity(W)
end

---------------------------------------------------------------------------------------------------------------

function window.setPosition( x,y )
	C.glfwSetWindowPos(W, x or 0, y or 0)
end

function window.getPosition()
	local x, y = ffi.new('int[1]'), ffi.new('int[1]')
	C.glfwGetWindowPos(W, x, y)
	return x[0], y[0]
end

---------------------------------------------------------------------------------------------------------------

function window.maximize()
	C.glfwMaximizeWindow(W)
end

function window.minimize()
	C.glfwIconifyWindow(W)
end

function window.restore()
	C.glfwRestoreWindow(W)
end

function window.focus()
	C.glfwFocusWindow(W)
end

function window.requestAttention()
	C.glfwRequestWindowAttention(W)
end

---------------------------------------------------------------------------------------------------------------

function window.setTitle( title )
	C.glfwSetWindowTitle(W, title)
	__params.title = title
end

function window.getTitle()
	return __params.title
end

---------------------------------------------------------------------------------------------------------------

function window.visible( state )
	if state then C.glfwShowWindow(W)
	else C.glfwHideWindow(W) end
end

function window.isVisible()
	return C.glfwGetWindowAttrib(W, C.GLFW_VISIBLE) == 1
end

---------------------------------------------------------------------------------------------------------------

function window.setFullscreen( state, fstype, index )
	index = index or 1
	index = check_monitor(index) and index-1 or 0
	local screenmode = C.glfwGetVideoMode( __monitors[index] )
	if state then
		assert(fstype == 'desktop' or fstype == 'exclusive', 'Invalid fullscreen type \''..tostring(fstype)..'\', expected one of : \'exclusive\' or \'desktop\'')
		
		if fstype == 'desktop' then
			C.glfwSetWindowAttrib(W, C.GLFW_DECORATED, 0)

			local mx, my = ffi.new('int[1]'), ffi.new('int[1]')
			C.glfwGetMonitorPos(__monitors[index], mx, my)

			C.glfwSetWindowMonitor(W, nil, mx[0],my[0], screenmode.width, screenmode.height, 0)
		elseif fstype == 'exclusive' then
			C.glfwSetWindowMonitor(W, __monitors[index], 0,0, screenmode.width, screenmode.height, 0)
		end

		__params.fullscreentype = fstype
		__params.fullscreen = true
	else
		__params.fullscreen = false
		__params.fullscreentype = nil

		if __params.x == nil or __params.y == nil then
			__params.x = math.random(0, screenmode.width*0.3)
			__params.y = math.random(0, screenmode.height*0.3)
			centered = false
		end

		C.glfwSetWindowAttrib(W, C.GLFW_DECORATED, __params.borderless and 0 or 1)
		C.glfwSetWindowMonitor(W, nil, __params.x, __params.y, __params.width, __params.height, 0)
	end
end

function window.getFullscreen()
	__params.fullscreen = C.glfwGetWindowMonitor(W) ~= nil
	return __params.fullscreen, __params.fullscreentype
end

---------------------------------------------------------------------------------------------------------------

function window.getMode()
	local flags = {}

	flags.fullscreen = C.glfwGetWindowMonitor(W) ~= nil
	flags.fullscreentype = __params.fullscreentype

	flags.x, flags.y = ffi.new('int[1]'), ffi.new('int[1]')
	C.glfwGetWindowPos(W, flags.x, flags.y)
	flags.x, flags.y = flags.x[0], flags.y[0]

	local width, height = ffi.new('int[1]'), ffi.new('int[1]')
	C.glfwGetWindowSize(W, width, height)
	width, height = width[0], height[0]

	flags.msaa = __params.msaa
	flags.vsync = __params.vsync

	flags.topmost = C.glfwGetWindowAttrib(W, C.GLFW_FLOATING) == 1
	flags.opacity = C.glfwGetWindowOpacity(W)

	flags.borderless = C.glfwGetWindowAttrib(W, C.GLFW_DECORATED) == 0
	flags.resizable = C.glfwGetWindowAttrib(W, C.GLFW_RESIZABLE) == 1
	flags.centered = __params.centered

	flags.display = __params.display

	flags.minwidth = __params.minwidth
	flags.minheight = __params.minheight
	
	return width, height, flags
end

function window.setMode( width, height, flags )
	if flags then
		local _, _, mode = window.getMode()
		for k,v in pairs(mode) do
			if not flags[k] or flags[k] == nil then
				flags[k] = v
			end
		end

		flags.display = check_monitor(flags.display) and flags.display or 1

		if flags.centered then
			local screenmode = C.glfwGetVideoMode( __monitors[flags.display-1] )
			local mx, my = ffi.new('int[1]'), ffi.new('int[1]')
			C.glfwGetMonitorPos(__monitors[flags.display-1], mx, my)

			flags.x = mx[0] + screenmode.width*0.5 - width*0.5
			flags.y = my[0] + screenmode.height*0.5 - height*0.5
		end
		C.glfwSetWindowPos(W, flags.x, flags.y)
		
		C.glfwSetWindowSizeLimits(W, flags.minwidth, flags.minheight, -1, -1)

		C.glfwSetWindowAttrib(W, C.GLFW_DECORATED, flags.borderless and 0 or 1)
		C.glfwSetWindowAttrib(W, C.GLFW_FLOATING, flags.topmost and 1 or 0)
		C.glfwSetWindowAttrib(W, C.GLFW_RESIZABLE, flags.resizable and 1 or 0)

		flags.opacity = math.max(0, math.min(flags.opacity, 1))
		C.glfwSetWindowOpacity(W, flags.opacity)

		if flags.fullscreen then
			window.setFullscreen(flags.fullscreen, flags.fullscreentype, flags.display)
		else
			C.glfwSetWindowSize(W, width, height)
		end

		__params.width = width
		__params.height = height 
		for k,v in pairs(flags) do
			__params[k] = v
		end
	else
		C.glfwSetWindowSize(W, width, height)
	end
end

---------------------------------------------------------------------------------------------------------------

C.glfwSetWindowMaximizeCallback(W, function( target, maximized )
	local width, height = ffi.new('int[1]'), ffi.new('int[1]')
	C.glfwGetWindowSize(W, width, height)
	lovr.event.push('maximized', maximized == 1, width[0], height[0])
end)

C.glfwSetWindowPosCallback(W, function( target, x,y )
	if lovr.windowmoved then
		lovr.windowmoved(x, y)
	end
end)

C.glfwSetDropCallback(W, function( target, count, c_paths )
	if lovr.dragdrop then
		local paths = {}
		for i=0, count-1 do
			table.insert(paths, C_str(c_paths[i]))
		end
		lovr.dragdrop(paths)
	end
end)

return window
