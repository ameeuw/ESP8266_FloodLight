fade = require("fade")

function startConfig()
     print('Config -> start webserver')
     print(node.heap())
     file.remove("init.lua")
     file.open("init.lua", "a+")
     file.writeline('dofile("config.lc")')
     file.close()
     tmr.delay(100000)
     node.restart()
end

function parseInput(sck, input)
    if input~=nil then
	--print(input)
    cmd, key = input:match("([^,]+)_([^,]+):")
    end
    if cmd~=nil and key~=nil then
        if cmd=="set" then
            if key=="rgb" then
                r,g,b=input:match(":(%d+),(%d+),(%d+)")
                if r~=nil and g~=nil and b~=nil then
                    pwm.setduty(pin_r, tonumber(r)*4)
                    pwm.setduty(pin_g, tonumber(g)*4)
                    pwm.setduty(pin_b, tonumber(b)*4)
                    print(r,g,b)
                end
            end
            
            if key=="btn" then
                btn,state=input:match(":(%d+),(%d+)")
                if btn~=nil and state~=nil then
                    pcall(loadstring("gpio.mode(pin_b"..btn..", gpio.OUTPUT)"))
                    pcall(loadstring("gpio.write(pin_b"..btn..","..state..")"))
                    print(btn,state) 
                end
            end
			
			if key=="fad" then
				state,saturation,lightness,speed=input:match(":(%d+),([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+)")
				if state~=nil and saturation~=nil and lightness~=nil and speed~=nil then
					if tonumber(state)~=0 then
						fade.start(tonumber(saturation),tonumber(lightness),tonumber(speed))
					else
						fade.stop()
					end
				end
			end
			
			if key=="str" then
				state,freq=input:match(":(%d+),(%d+)")
				if state~=nil and r~=nil and g~=nil and b~=nil and freq~=nil then
					if tonumber(state)~=0 then
						fade.startStrobe(tonumber(r),tonumber(g),tonumber(b),tonumber(freq))
					else
						fade.stop()
					end
				end
			end
            
        end
        
        if cmd=="get" then
            if key=="rgb" then
                -- Do stuff to reply to "get" command
            end
            if key=="btn" then
                -- Do stuff to reply to "get" command
            end
        end
    end
end

function runClient()
     node.output(function(str) if str=="DNS Fail!\n" then runClient() blink(pin_r, 2, 250) end end, 1)
     sk=net.createConnection(net.TCP, 0)
     print("Resolving '"..host.."'")
     sk:dns(host, function(conn, ip) 
								if ip~=nil then
									print("Connecting to "..ip)
									sk:connect(port, ip)
								end
							end)                       
     sk:on("receive", parseInput)
     sk:on("disconnection", runClient)
     sk:on("connection", function(sck) print("Connected.") blink(pin_g,3, 250) end)
end

function blink(pin, times, delay)	
	local lighton=0
	local count=0
	tmr.alarm(0,delay,1,
		function()
			if lighton==0 then 
				lighton=1 
				pwm.setduty(pin, 15)
			else 
				lighton=0
				pwm.setduty(pin, 0)
			end
			if count==(times*2-1) then 
				tmr.stop(0) 
			else		
				count=count+1
			end
		end)
end

function checkLongPress()
    gpio.mode(pin_reset,gpio.OUTPUT)
	gpio.write(pin_reset,gpio.HIGH)
	tmr.alarm(1,500,0,function()
		if gpio.read(pin_reset)~=gpio.HIGH then
			startConfig()
		else
			gpio.mode(pin_reset,gpio.INT,gpio.PULLUP)
			gpio.trig(pin_reset,"low",checkLongPress)
		end
	end)
end

if file.open('settings.lua', 'r') then 
     dofile('settings.lua')
	 
	 wifi.setmode(wifi.STATION)
	 wifi.sta.config(network, password)
	 wifi.sta.autoconnect(1)
	 tmr.delay(100000)
	 
	 pin_reset=3
     pin_b1=4
     pin_b2=4
     pin_b3=4
     pin_r=5
     pin_g=6
     pin_b=7
     gpio.mode(pin_reset,gpio.INT,gpio.PULLUP)
     gpio.trig(pin_reset,"low",checkLongPress)
     pwm.setup(pin_r,300,0)
     pwm.setup(pin_g,300,0)
     pwm.setup(pin_b,300,0)
     pwm.start(pin_r)
     pwm.start(pin_g)
     pwm.start(pin_b)
     runClient()
else
     startConfig()
end
