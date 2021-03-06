function updateAP()
	wifi.setmode(wifi.STATION)
	wifi.sta.disconnect()
	wifi.sta.getap(function(aplist) if aplist~=nil then networks={} for k,v in pairs(aplist) do networks[#networks+1]=k end createServer() else tmr.delay(500000) updateAP() end end)
	tmr.delay(100000)
	wifi.setmode(wifi.STATIONAP)
	cfg={}
	cfg.ssid="RGB_Floodlight"
	--cfg.pwd="12341234"
	wifi.ap.config(cfg)
	tmr.delay(250000)
	print(wifi.ap.getip())
end

function applySettings(network, password, host, port)
	file.remove("settings.lua")
	file.open("settings.lua", "a+")
	file.writeline('network="'..network..'"')
	file.writeline('password="'..password..'"')
	file.writeline('host="'..host..'"')
	file.writeline('port=tonumber("'..port..'")')
	file.close()
	file.remove("init.lua")
	file.open("init.lua", "a+")
	file.writeline('dofile("client.lc")')
	file.close()
end

function parsePayload(payload)
	local network, password, host, port = payload:match("network=([^,]+)&password=([^,]+)&host=([^,]+)&port=([^,]+)")
	if network~=nil and password~=nil and host~=nil and port~=nil then
		payload=nil
		print(network,password,host,port)
		applySettings(network,password,host,port)
		tmr.delay(100000)
		wifi.setmode(wifi.STATION)
		wifi.sta.config(network, password)
		wifi.sta.autoconnect(1)
		tmr.delay(100000)
		node.restart()
	end
end

function createServer()
	srv=net.createServer(net.TCP) srv:listen(80,function(conn)
	conn:on("receive",function(conn,payload)
	parsePayload(payload)
	conn:send([[<html><head><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"/><style>*{font-size:110%;text-align:center;font-family:Arial;}</style></head><body><b>ESP8266 Config<form action="." method="post">
	<select style="width:100%;" name="network">
	<option>]]..table.concat(networks,"</option><option>")..[[</option></select><br>
	<input style="width:100%;" type="password" name="password" placeholder="Password"><br>
	<input style="width:100%;" type="text" name="host" value="]]..tostring(host)..[["><br>
	<input style="width:100%;" type="number" name="port" value="]]..tostring(port)..[["><br>
	<input style="width:100%;" type="submit" value="Apply settings"/></body></html>]])end)
	conn:on("sent",function(conn) conn:close() end)end)
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

if file.open('settings.lua', 'r') then 
	dofile('settings.lua')
else
	host = "URL or IP"
	port = "Port"
end
 pin_r=5
 pin_g=6
 pin_b=7
 pwm.setup(pin_r,300,0)
 pwm.setup(pin_g,300,0)
 pwm.setup(pin_b,300,0)
 blink(pin_b,-1,500)
 updateAP()
