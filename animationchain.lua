local M={}
animationchain=M

local transition=transition
local setmetatable=setmetatable

setfenv(1,M)

local function start(anim,options,onStart,onComplete)
	return function()
		options.onComplete=onComplete
		anim()
		if onStart then
			onStart()
		end
	end
end

-- exec is the function that starts the animation from the previous call
function chainFunctions(exec,options,runParent)
	local t={}

	local mt={
		__index=function(t,k)
			local run=function(execChildAnim)
				local doIt
				-- wrap child animation in relation to previous call
				local onStart,onComplete
				if k=="onStart" or k=="whenStart" then
					onStart=execChildAnim
				elseif k=="onComplete" or k=="whenDone" then
					onComplete=execChildAnim
				end
				
				doIt=start(exec,options,onStart,onComplete)
				
				if runParent then
					runParent(doIt)
				else
					doIt()
				end
			end

			return function(...)
				if k=="start" then
					return run()
				end
					
				return anim(arg[1],arg[2],run)
			end
		end
	}

	setmetatable(t,mt)
	return t

end

function anim(obj,options,runParent)
	return chainFunctions(function () return transition.to(obj,options) end, options,runParent)
end

return M