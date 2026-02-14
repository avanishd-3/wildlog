from openai import OpenAI
import gspread

CHATGPT_API_KEY = "PLACEHOLDER"
PROMPT = ("\"This region that enticed and influenced President Theodore Roosevelt consists of a park of three units in the northern badlands. "
            "Besides Roosevelt's historic cabin, there are numerous scenic drives and backcountry hiking opportunities. Wildlife includes American "
            "bison, pronghorn, bighorn sheep, and wild horses.\" - Theodore Roosevelt \"Covering most of Mount Desert Island and other coastal "
            "islands, Acadia features the tallest mountain on the Atlantic coast of the United States, granite peaks, ocean shoreline, woodlands, "
            "and lakes. There are freshwater, estuary, forest, and intertidal habitats.\" - Acadia \"The southernmost national park is on three "
            "Samoan islands in the South Pacific. It protects coral reefs, rainforests, volcanic mountains, and white beaches. The area is also home "
            "to flying foxes, brown boobies, sea turtles, and 900 species of fish.\" - American Samoa Make a description like the examples above "
            "which are descriptions of other national parks for ")


client = OpenAI(api_key=CHATGPT_API_KEY)

def chatgpt_prompt(park: str):
    response = client.responses.create(
        model="gpt-5-nano",
        input=PROMPT + park
    )
    
    return response.output_text

gc = gspread.service_account(filename="nature-letterbox-b9eba28111c4.json")
sh = gc.open("National Park Data")
ws = sh.sheet1

'''
national_parks = ws.col_values(2)[1:]

for index, park in enumerate(national_parks):
    index = index + 2
    ws.update_acell(f"C{index}", chatgpt_prompt(park))
    print(f"C{index} updated")
'''

state_parks = ws.col_values(2)[473:]

for index, park in enumerate(state_parks):
    index = index + 474
    ws.update_acell(f"C{index}", chatgpt_prompt(park))
    print(f"C{index} updated")