import json
import gspread
import time

gc = gspread.service_account(filename="PLACEHOLDER")
sh = gc.open("National Park Data")
ws = sh.sheet1

with open("feespasses.json", "r", encoding="utf-8") as f:
    feespasses = json.load(f)

park_code_dict = dict()

park_codes = ws.col_values(1)[1:]

for index, code in enumerate(park_codes):
    park_code_dict[code] = index + 2


for park in feespasses["data"]:
    
    park_code = park["parkCode"]
    print("Processing park code: ", park_code)

    if park_code not in park_code_dict.keys():
        print("Code {park_code} doesn't exist")
        continue

    if not park["isFeeFreePark"]:
        if len(park["fees"]) > 0:
            ws.update_acell(f"J{park_code_dict[park_code]}", park["fees"][0]["cost"])
            print(f"Updated Cost for J{park_code_dict[park_code]} to {park["fees"][0]["cost"]}")
    else:
        ws.update_acell(f"J{park_code_dict[park_code]}", 0)
        print(f"Updated Cost for J{park_code_dict[park_code]} to 0")

    ws.update_acell(f"I{park_code_dict[park_code]}", park["isFeeFreePark"])
    print(f"Updated Free for I{park_code_dict[park_code]}")

    time.sleep(5)


