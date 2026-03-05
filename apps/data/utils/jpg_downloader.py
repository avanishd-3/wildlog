import requests
import gspread
from io import BytesIO
from PIL import Image
import time

gc = gspread.service_account(filename="./wildlog/apps/data/utils/nature-letterbox-afae0ffe65ef.json")
sh = gc.open("Park Data")
ws = sh.sheet1


park_code_dict = dict()
park_codes = ws.col_values(1)[1:]

for index, code in enumerate(park_codes):
    park_code_dict[code] = index + 2

headers = {'User-Agent': 'Mozilla/5.0'}

for index in range(2, 761):
    park_name = ws.acell(f"B{index}").value
    link = ws.acell(f"K{index}").value
    
    try:
        resp = requests.get(link, headers=headers)
        resp.raise_for_status()
        img = Image.open(BytesIO(resp.content))
        img.convert("RGB").save(f"park_images/{park_name}.jpg", "JPEG")
        print(f"Saved {link} as jpg, for {park_name}")
    except Exception as e:
        print(f"Failed to save {link} as jpg, for {park_name}, error: {e}")

    time.sleep(5)
    


