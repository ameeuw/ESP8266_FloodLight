local fade = {}

local function hslToRgb(h, s, l)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    function hue2rgb(p, q, t)
      if t < 0   then t = t + 1 end
      if t > 1   then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function setRGB(r,g,b)
	pwm.setduty(pin_r, tonumber(r))
    pwm.setduty(pin_g, tonumber(g))
    pwm.setduty(pin_b, tonumber(b))
end

function fade.start(saturation,lightness,speed)
	tmr.stop(2)
	tmr.alarm(2,50,1,function()
		if h < 1 then
			setRGB(hslToRgb(h,saturation,lightness))
			h = h + speed
		else
			h = 0
		end
	end)
end

function fade.stop()
	tmr.stop(2)
end

function fade.startStrobe(r,g,b,freq)
	tmr.stop(2)
	state=0
	delay=500/freq
	print(delay)
	tmr.alarm(2,delay,1,function()
		if state==0 then
			setRGB(r,g,b)
			state=1
		else
			setRGB(0,0,0)
			state=0
		end		
	end)
end


h = 0
return fade