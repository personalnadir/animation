local M={}
animationchain=M

local transition=transition
local setmetatable=setmetatable
local type=type
local error=error

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
function chainFunctions(exec,options,runParent,noanim)
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
				if noanim then
					error("animationchain: passing in pure functions must terminate the chain. Only call start after passing a single function into the chain")
				end
				if #arg==1 and type(arg[1])=="function" then
					-- just a function has been passed in. 
					return chainFunctions(arg[1],{},run,true)
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