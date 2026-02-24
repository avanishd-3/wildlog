import json
import gspread
import time

gc = gspread.service_account(filename="PLACEHOLDER")
sh = gc.open("Park Data")
ws = sh.sheet1

with open("parks.json", "r", encoding="utf-8") as f:
    images = json.load(f)

park_code_dict = dict()

park_codes = ws.col_values(1)[1:]

for index, code in enumerate(park_codes):
    park_code_dict[code] = index + 2


for park in images["data"]:
    
    park_code = park["parkCode"]
    print("Processing park code: ", park_code)

    if park_code not in park_code_dict.keys():
        print("Code {park_code} doesn't exist")
        continue
    
    if len(park["images"]) > 0 and len(park["images"][0]["url"]) > 0:
        ws.update_acell(f"K{park_code_dict[park_code]}", park["images"][0]["url"])
        print(f"Updated Cost for K{park_code_dict[park_code]} to {park["images"][0]["url"]}")

    time.sleep(5)


