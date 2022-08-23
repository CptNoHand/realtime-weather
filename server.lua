GlobalState.weatherCode = nil

local presetLocations = {
	['berlin'] = { lat = 52.52, long = 13.41 },
	['paris'] = { lat = 48.85, long = 2.35 },
	['london'] = { lat = 51.50, long = -0.13 },
	['madrid'] = { lat = 40.42, long = -3.70 },
	['amsterdam'] = { lat = 52.37, long = 4.89 },
}

local function DebugLog(string, ...)
	if GetConvar('weather_debugMode', 'false') == 'true' then
		local string = tostring(string)
		print(string:format(...))
	end
end

local function RequestWeather(cb)
	local requestStart = GetGameTimer()
	local latitude = GetConvar('weather_latitude', '0')
	local longitude = GetConvar('weather_longitude', '0')
	local location = string.lower(GetConvar('weather_presetLocation', 'paris'))

	if (latitude == '0') and (longitude == '0') and presetLocations[location] then
		latitude = presetLocations[location].lat
		longitude = presetLocations[location].long
	end

	local url = ('https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current_weather=true'):format(latitude,
		longitude)

	if GetConvar('weather_useFahrenheit', 'false') == 'true' then
		url = url .. '&temperature_unit=fahrenheit'
	end

	DebugLog('Weather data update starting for %s (latitude) %s (longitude)', latitude, longitude)
	PerformHttpRequest(url, function(errorCode, resultData)
		local resultObject = json.decode(resultData)
		
		if errorCode == 400 or not resultObject then
			return DebugLog('Weather data update failed')
		end

		DebugLog('Weather data update finished in %d ms', GetGameTimer() - requestStart)
	end)
end

local function UpdateWeather()
	RequestWeather(function(weather)
		local currentWeather = weather.current_weather
		local weatherCode = math.floor(currentWeather.weathercode)
		GlobalState.weatherCode = weatherCode
		GlobalState.temperature = currentWeather.temperature

		DebugLog('New weather code: %d', weatherCode)
	end)
end

CreateThread(function()
	while true do
		UpdateWeather()
		Wait(GetConvarInt('weather_updateFrequency', 600000))
	end
end)

RegisterNetEvent('realtimeWeather:requestTime', function()
	if GetConvar('weather_realtimeTime', 'false') == 'false' then return end

	DebugLog('Updating realtime time for %d', source)
	TriggerClientEvent('realtimeWeather:updateTime', source, os.date('*t'))
end)
