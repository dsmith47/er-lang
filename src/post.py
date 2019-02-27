#!/usr/bin/env python3

import requests

r = requests.post("http://localhost:8081", data={'row': 1, 'col': 5, 'color': 101})
print(r.text)
