#!/usr/bin/python
import os
import requests
import time
LAT = 41.1537
LON = -81.3579
API_KEY = os.environ['OPEN_WEATHER_MAP_API_KEY']
res = requests.get(f'https://api.openweathermap.org/data/2.5/weather?lat={LAT}&lon={LON}&units=imperial&appid={API_KEY}')
json = res.json()
weather = json['weather'][0]['description']
temperature = json['main']['temp']
with open(os.path.expanduser('~/.weather'), 'w') as weather_file:
	weather_file.write(f'{round(temperature)}F, {weather}')
