local canEnableSnow = GetConvar("weather_snow", "false") == "true"
local weatherCodes = {
	[0]  = { type = "extrasunny", title = "Clear sky" },
	[1]  = { type = "neutral", title = "Mainly clear" },
	[2]  = { type = "clouds", title = "Partly cloudy" },
	[3]  = { type = "overcast", title = "Overcast" },
	[45] = { type = "fog", title = "Fog" },
	[48] = { type = "smog", title = "Depositing rime fog" },
	[51] = { type = "rain", title = "Drizzle light" },
	[53] = { type = "rain", title = "Drizzle moderate" },
	[55] = { type = "rain", title = "Drizzle dense" },
	[56] = { type = "blizzard", title = "Freezing drizzle light" },
	[57] = { type = "blizzard", title = "Freezing drizzle heavy" },
	[61] = { type = "rain", title = "Rain slight" },
	[63] = { type = "rain", title = "Rain moderate" },
	[65] = { type = "rain", title = "Rain heavy" },
	[66] = { type = "blizzard", title = "Freezing rain light" },
	[67] = { type = "blizzard", title = "Freezing rain heavy" },
	[71] = { type = "snow", title = "Snow fall slight" },
	[73] = { type = "xmas", title = "Snow fall moderate" },
	[75] = { type = "xmas", title = "Snow fall heavy" },
	[77] = { type = "xmas", title = "Snow grains" },
	[80] = { type = "rain", title = "Rain showers slight" },
	[81] = { type = "rain", title = "Rain showers moderate" },
	[82] = { type = "rain", title = "Rain showers violent" },
	[85] = { type = "snow", title = "Snow showers slight" },
	[86] = { type = "snow", title = "Snow showers heavy" },
	[95] = { type = "thunder", title = "Thunderstorm" }, -- only available in central europe
	[96] = { type = "thunder", title = "Thunderstorm slight hail" }, -- only available in central europe
	[99] = { type = "thunder", title = "Thunderstorm heavy hail" }, -- only available in central europe
}

local function setWeatherByCode(code, instant)
	if not GlobalState.freezeWeather then
		local weather = weatherCodes[code]

		if canEnableSnow then
			if weather.type == "xmas" or weather.type == "snow" then
				SetForceVehicleTrails(true)
				SetForcePedFootstepsTracks(true)
			else
				SetForceVehicleTrails(false)
				SetForcePedFootstepsTracks(false)
			end
		end
	
		SetWeatherTypeOvertimePersist(weather.type, instant and 0.0 or 15.0)
	end
end

CreateThread(function()
	SetWeatherOwnedByNetwork(false)

	if GlobalState.weatherType then
		SetWeather(GlobalState.weatherType, true)
	end
end)

AddStateBagChangeHandler('weatherType', 'global', function(bagName, key, value)
	SetWeather(value)
end)

RegisterNetEvent("realtimeWeather:updateTime", function(now, freezed)
	SetMillisecondsPerGameMinute(freezed and 0 or 60000)
	NetworkOverrideClockTime(now.hour, now.min, now.sec)
end)

TriggerServerEvent("realtimeWeather:requestTime")

-- if hour or min are nil the time will be resynced with the real time
export("setTime", function(hour, min)
	TriggerServerEvent("realtimeWeather:setTime", tonumber(hour), tonumber(min))
end)

export("setWeather", function(weatherType)
	local weatherCode = 0

	for code, data in pairs(weatherCodes) do
		if data.type == weatherType then
			weatherCode = code
			break
		end
	end

	TriggerServerEvent("realtimeWeather:setWeather", weatherCode)
end)

export("freezeTime", function(status)
	TriggerServerEvent("realtimeWeather:freezeTime", status)
end)
