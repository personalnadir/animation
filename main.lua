require "animationchain"

local stops={
	{x=20},
	{y=20},
	{x=200,simul=true},
	{y=600},
	{x=display.contentCenterX,y=display.contentCenterY,delete=true}
}

local x,y=display.contentCenterX,display.contentCenterY
for k,v in ipairs(stops) do
	x,y=(v.x or x), (v.y or y)
	if not v.simul then
		display.newCircle(x,y,10):setFillColor(255,0,0)
	end
end

local c=display.newCircle(display.contentCenterX,display.contentCenterY,20)
animationchain.anim(c,stops[1]).whenDone(c,stops[2]).whenDone(c,stops[3]).whenStart(c,stops[4]).onComplete(c,stops[5]).onStart(function() print("done") end).start()