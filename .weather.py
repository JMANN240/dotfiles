#!/usr/bin/python
import os
import requests
import time
LAT = YOUR_LATITUDE
LON = YOUR_LONGITUDE
API_KEY = YOUR_OPEN_WEATHER_MAP_API_KEY
res = requests.get(f'https://api.openweathermap.org/data/2.5/weather?lat={LAT}&lon={LON}&units=imperial&appid={API_KEY}')
json = res.json()
weather = json['weather'][0]['description']
temperature = json['main']['temp']
with open(os.path.expanduser('~/.weather'), 'w') as weather_file:
	weather_file.write(f'{round(temperature)}F, {weather}')
