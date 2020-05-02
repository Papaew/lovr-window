local ffi = require 'ffi'
local C = ffi.os == 'Windows' and ffi.load('glfw3') or ffi.C

ffi.cdef [[
	enum {
		GLFW_RESIZABLE = 0x00020003,
		GLFW_VISIBLE = 0x00020004,
		GLFW_DECORATED = 0x00020005,
		GLFW_FLOATING = 0x00020007
	};

	typedef struct GLFWwindow GLFWwindow;
	GLFWwindow* glfwGetCurrentContext(void);
	
	typedef struct GLFWmonitor GLFWmonitor;
	GLFWmonitor* glfwGetWindowMonitor(GLFWwindow *window);
	GLFWmonitor* glfwGetPrimaryMonitor(void);
	
	typedef struct GLFWvidmode {
		int width;
		int height;
		int refreshRate;
	} GLFWvidmode;
	const GLFWvidmode* glfwGetVideoMode(GLFWmonitor* monitor);
	void glfwSetWindowMonitor(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);

	void glfwSetWindowAttrib(GLFWwindow* window, int attrib, int value);
	int glfwGetWindowAttrib(GLFWwindow* window, int attrib);
	
	void glfwSetWindowSize(GLFWwindow* window, int width, int height);
	void glfwGetWindowSize(GLFWwindow* window, int *width, int *height);
	void glfwSetWindowSizeLimits(GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight);

	void glfwSetWindowPos(GLFWwindow* window, int xpos, int ypos);
	void glfwGetWindowPos(GLFWwindow* window, int *xpos, int *ypos);

	void glfwMaximizeWindow(GLFWwindow* window);
	void glfwIconifyWindow(GLFWwindow *window);
	void glfwRestoreWindow(GLFWwindow *window);

	void glfwSetWindowTitle(GLFWwindow* window, const char* title);
	
	void glfwShowWindow(GLFWwindow* window);
	void glfwHideWindow(GLFWwindow* window);

	void glfwFocusWindow(GLFWwindow* window);

	void glfwRequestWindowAttention(GLFWwindow* window);

	void glfwSetWindowOpacity(GLFWwindow* window, float opacity);
	float glfwGetWindowOpacity(GLFWwindow* window);

	typedef void(*GLFWwindowmaximizefun) (GLFWwindow*, int);
	GLFWwindowmaximizefun glfwSetWindowMaximizeCallback(GLFWwindow* window, GLFWwindowmaximizefun callback);
	
]]
local W = C.glfwGetCurrentContext()
local monitor = C.glfwGetWindowMonitor(W)
---------------------------------------------------------------------------------------------------------------
local window = {}
for k,v in pairs(w) do
	window[k] = v
end
window.canvas = lovr.graphics.newCanvas(window.width, window.height, {format = 'rgba', stereo = false, msaa = window.msaa, mipmaps = false})
w = nil
---------------------------------------------------------------------------------------------------------------
local function _resize_callback(w, h)
	window.canvas = lovr.graphics.newCanvas(w, h, {format = 'rgba', stereo = false, msaa = window.msaa, mipmaps = false})
	lovr.event.push('resize', w, h)
end
---------------------------------------------------------------------------------------------------------------
local function _windowRender()
	lovr.graphics.setCanvas(window.canvas)
	lovr.graphics.clear()
	lovr.draw()
	lovr.graphics.setCanvas()
	lovr.graphics.setColor(1, 1, 1)
	lovr.graphics.fill(window.canvas:getTexture())
end

function lovr.run()
	lovr.timer.step()
	if lovr.load then lovr.load() end
	return function()
		lovr.event.pump()
		for name, a, b, c, d in lovr.event.poll() do
			if name == 'quit' and (not lovr.quit or not lovr.quit()) then
				return a or 0
			end
			if lovr.handlers[name] then lovr.handlers[name](a, b, c, d) end
		end
		local dt = lovr.timer.step()
		if lovr.headset then
			lovr.headset.update(dt)
		end
		if lovr.audio then
			lovr.audio.update()
			if lovr.headset then
				lovr.audio.setOrientation(lovr.headset.getOrientation())
				lovr.audio.setPosition(lovr.headset.getPosition())
				lovr.audio.setVelocity(lovr.headset.getVelocity())
			end
		end
		if lovr.update then lovr.update(dt) end
		if lovr.graphics then
			lovr.graphics.origin()
			if lovr.draw then
				if lovr.headset then
					lovr.headset.renderTo(_windowRender)
				end
				if lovr.graphics.hasWindow() then
					lovr.mirror()
				end
			end
			lovr.graphics.present()
		end
	end
end
---------------------------------------------------------------------------------------------------------------
function window.focus()
	C.glfwFocusWindow(W)
end
---------------------------------------------------------------------------------------------------------------
function window.requestAttention()
	C.glfwRequestWindowAttention(W)
end
---------------------------------------------------------------------------------------------------------------
function window.setOpacity(value)
	value = math.max(0, math.min(value, 1))
	C.glfwSetWindowOpacity(W, value)
end

function window.getOpacity()
	return C.glfwGetWindowOpacity(W)
end
---------------------------------------------------------------------------------------------------------------
function window.setPosition(x,y)
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
---------------------------------------------------------------------------------------------------------------
function window.setTitle(title)
	C.glfwSetWindowTitle(W, title)
	window.title = title
end

function window.getTitle()
	return window.title
end
---------------------------------------------------------------------------------------------------------------
function window.visible(state)
	if state then C.glfwShowWindow(W)
	else C.glfwHideWindow(W) end
end

function window.isVisible()
	return C.glfwGetWindowAttrib(W, C.GLFW_VISIBLE) == 1
end
---------------------------------------------------------------------------------------------------------------
function window.setMode(width, height, flags)
	C.glfwSetWindowSize(W, width, height)

	if flags then
		local screenmode = C.glfwGetVideoMode(C.glfwGetPrimaryMonitor())

		local _, _, mode = window.getMode()
		for k,v in pairs(mode) do
			if not flags[k] or flags[k] == nil then
				flags[k] = v
			end
		end

		window.setTitle(flags.title)
		
		if flags.centered then
			flags.x = screenmode.width*0.5-width*0.5
			flags.y = screenmode.height*0.5-height*0.5
			C.glfwSetWindowMonitor(W, nil, flags.x, flags.y, width, height, -1)
		else
			C.glfwSetWindowMonitor(W, nil, flags.x or math.random(0, screenmode.width*0.3), flags.y or math.random(0, screenmode.width*0.3), width, height, -1)
		end
		
		C.glfwSetWindowSizeLimits(W, flags.minwidth, flags.minheight, -1, -1)

		C.glfwSetWindowAttrib(W, C.GLFW_DECORATED, flags.borderless and 0 or 1)
		C.glfwSetWindowAttrib(W, C.GLFW_FLOATING, flags.topmost and 1 or 0)
		C.glfwSetWindowAttrib(W, C.GLFW_RESIZABLE, flags.resizable and 1 or 0)

		flags.opacity = math.max(0, math.min(flags.opacity, 1))
		C.glfwSetWindowOpacity(W, flags.opacity)

		window.width = width
		window.height = height 
		for k,v in pairs(flags) do
			window[k] = v
		end

		window.setFullscreen(window.fullscreen, window.fullscreentype)
	end
end

function window.getMode()
	local flags = {}
	flags.title = window.getTitle()
	flags.x, flags.y = ffi.new('int[1]'), ffi.new('int[1]')
	C.glfwGetWindowPos(W, flags.x, flags.y)
	flags.x, flags.y = flags.x[0], flags.y[0]

	local width, height = ffi.new('int[1]'), ffi.new('int[1]')
	C.glfwGetWindowSize(W, width, height)
	width, height = width[0], height[0]

	flags.minwidth, flags.minheight = window.minwidth, window.minheight

	flags.centered = window.centered
	flags.topmost = window.topmost

	flags.borderless = C.glfwGetWindowAttrib(W, C.GLFW_DECORATED) == 0
	flags.resizable = C.glfwGetWindowAttrib(W, C.GLFW_RESIZABLE) == 1
	flags.opacity = C.glfwGetWindowOpacity(W)

	flags.msaa = window.msaa
	
	return width, height, flags
end
---------------------------------------------------------------------------------------------------------------
function window.setFullscreen(state, fstype)
	local screenmode = C.glfwGetVideoMode(C.glfwGetPrimaryMonitor())
	if state then
		fstype = fstype or 'desktop'
		assert(fstype == 'desktop' or fstype == 'exclusive', 'Invalid fullscreen type \''..tostring(fstype)..'\', expected one of : \'exclusive\' or \'desktop\'')
		
		if fstype == 'desktop' then
			window.fullscreentype = 'desktop'
			C.glfwSetWindowAttrib(W, C.GLFW_DECORATED, 0)
			C.glfwSetWindowMonitor(W, nil, 0,0, screenmode.width, screenmode.height, -1)
		elseif fstype == 'exclusive' then
			window.fullscreentype = 'exclusive'
			C.glfwSetWindowMonitor(W, C.glfwGetPrimaryMonitor(), 0,0, screenmode.width, screenmode.height, -1)
		end
		window.fullscreen = true
		_resize_callback(screenmode.width, screenmode.height)
	else
		window.fullscreen = false
		window.fullscreentype = nil

		if window.x == nil or window.y == nil then
			window.x = math.random(0, screenmode.width*0.3)
			window.y = math.random(0, screenmode.height*0.3)
			centered = false
		end

		C.glfwSetWindowAttrib(W, C.GLFW_DECORATED, window.borderless and 0 or 1)
		C.glfwSetWindowMonitor(W, nil, window.x, window.y, window.width, window.height, -1)
		_resize_callback(window.width, window.height)
	end
end

function window.getFullscreen()
	return window.fullscreen, window.fullscreentype
end
---------------------------------------------------------------------------------------------------------------
C.glfwSetWindowMaximizeCallback(W, function(target, maximized)
	if target == W then
		local width, height = ffi.new('int[1]'), ffi.new('int[1]')
		C.glfwGetWindowSize(W, width, height)
		_resize_callback(width[0], height[0])
		lovr.event.push('maximized', maximized == 1)
	end
end)
---------------------------------------------------------------------------------------------------------------
window.setMode(window.width, window.height, {
							title = window.title,
							fullscreen = window.fullscreen,
							fullscreentype = window.fullscreentype,
							minwidth = window.minwidth,
							minheight = window.minheight,
							x = window.x,
							y = window.y,
							centered = window.centered,
							topmost = window.topmost,
							borderless = window.borderless,
							resizable = window.resizable,
							opacity = window.opacity,
							msaa = window.msaa,
							framelimit = window.framelimit})

return window
