#!/usr/bin/env python3

import requests

r = requests.post("http://localhost:80", data={'row': 1, 'col': 5, 'color': "101"})
print(r.text)
