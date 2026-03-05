#!/usr/bin/env python3
"""
California State Parks Image Scraper — No API Keys Needed
==========================================================
Downloads one JPG image per park from 4 free sources:

  1. Wikimedia Commons
  2. Wikipedia article thumbnail
  3. Wikipedia page images (deeper dig)
  4. iNaturalist observation photos

Usage:
    pip install requests Pillow
    python park_image_scraper.py

Re-runnable — skips already-downloaded images.
Images: ./park_images/*.jpg
Log:    ./park_images/scrape_log.csv
"""

import os, re, time, csv, requests

OUTPUT_DIR = "park_images"
IMAGE_WIDTH = 800
DELAY = 1.0
TIMEOUT = 20
MIN_IMAGE_BYTES = 5000

PARKS = """Admiral William Standley State Recreation Area
Ahjumawi Lava Springs State Park
Albany State Marine Reserve
Anderson Marsh State Historic Park
Andrew Molera State Park
Angel Island State Park
Trione Annadel State Park
Ano Nuevo State Park
Antelope Valley CA Poppy State Natural Reserve
Antelope Valley Indian Museum
Anza-Borrego Desert State Park
Armstrong Redwoods State Natural Reserve
Arthur B Ripley Desert State Park
Asilomar State Beach
Auburn State Recreation Area
Austin Creek State Recreation Area
Azalea State Natural Reserve
Bale Grist Mill State Historic Park
Bean Hollow State Beach
Benbow Lake State Recreation Area
Benicia Capitol State Historic Park
Benicia State Recreation Area
Bethany Reservoir State Recreation Area
Bidwell Mansion State Historic Park
Bidwell Sacramento River State Park
Big Basin Redwoods State Park
Bodie State Historic Park
Bolsa Chica State Beach
Border Field State Park
Bothe Napa Valley State Park
Brannan Island State Recreation Area
Burleigh H Murray Ranch Park Property
Burton Creek State Park
Butano State Park
Calaveras Big Trees State Park
California Citrus State Historic Park
CA Indian Heritage Center State Park
CA State Capitol Museum Park Property
CA Mining and Mineral Museum
CA Railroad Museum Point of Interest
Cambria State Marine Park
Candlestick Point State Recreation Area
Cardiff State Beach
Carlsbad State Beach
Carmel River State Beach
Carnegie State Vehicular Recreation Area
Carpinteria State Beach
Caspar Headlands State Beach
Caspar Headlands State Natural Reserve
Castaic Lake State Recreation Area
Castle Crags State Park
Castle Rock State Park
Castro Adobe Park Property
Caswell Memorial State Park
Cayucos State Beach
China Camp State Park
Chino Hills State Park
Chumash Painted Cave State Historic Park
Clay Pit State Vehicular Recreation Area
Clear Lake State Park
Colonel Allensworth State Historic Park
Columbia State Historic Park
Colusa Sacramento River State Recreation Area
Corona del Mar State Beach
Crystal Cove State Park
Cuyamaca Rancho State Park
DL Bliss State Park
Del Norte Coast Redwoods State Park
Delta Meadows Park Property
Dockweiler State Beach
Doheny State Beach
Donner Memorial State Park
McLaughlin Eastshore State Park Sea Shore
Ed Z'Berg Sugar Pine Point State Park
El Capitan State Beach
Emerald Bay State Park
Emeryville Crescent State Marine Reserve
Emma Wood State Beach
Empire Mine State Historic Park
Estero Bluffs State Park
Folsom Lake State Recreation Area
Folsom Powerhouse State Historic Park
Fort Humboldt State Historic Park
Fort Ord Dunes State Park
Fort Ross State Historic Park
Fort Tejon State Historic Park
Franks Tract State Recreation Area
Fremont Peak State Park
Garrapata State Park
Gaviota State Park
George J Hatfield State Recreation Area
Gray Whale Cove State Beach
Great Valley Grasslands State Park
Greenwood State Beach
Grizzly Creek Redwoods State Park
Grover Hot Springs State Park
Half Moon Bay State Beach
Harmony Headlands State Park
Harry A Merlo State Recreation Area
Hearst San Simeon State Historical Monument
Hearst San Simeon State Park
Heber Dunes State Vehicular Recreation Area
Hendy Woods State Park
Henry Cowell Redwoods State Park
Henry W Coe State Park
Hollister Hills State Vehicular Recreation Area
Humboldt Lagoons State Park
Humboldt Redwoods State Park
Hungry Valley State Vehicular Recreation Area
Huntington State Beach
Indian Grinding Rock State Historic Park
Indio Hills Palms Park Property
Jack London State Historic Park
Jedediah Smith Redwoods State Park
John B Dewitt Redwoods State Natural Reserve
John Little State Natural Reserve
Jug Handle State Natural Reserve
Julia Pfeiffer Burns State Park
Kenneth Hahn State Recreation Area
Kings Beach State Recreation Area
Kruse Rhododendron State Natural Reserve
La Purisima Mission State Historic Park
Lake Del Valle State Recreation Area
Lake Oroville State Recreation Area
Lake Perris State Recreation Area
Lake Valley State Recreation Area
Leland Stanford Mansion State Historic Park
Leo Carrillo State Park
Leucadia State Beach
Lighthouse Field State Beach
Limekiln State Park
Little River State Beach
Los Angeles State Historic Park
Los Osos Oaks State Natural Reserve
MacKerricher State Park
Mailliard Redwoods State Natural Reserve
Malakoff Diggins State Historic Park
Malibu Creek State Park
Malibu Lagoon State Beach
Manchester State Park
Mandalay State Beach
Manresa State Beach
Marconi Conference Center State Historic Park
Marina State Beach
Marshall Gold Discovery State Historic Park
Martial Cottle Park State Recreation Area
McArthur Burney Falls State Park
McConnell State Recreation Area
McGrath State Beach
Mendocino Headlands State Park
Mendocino Woodlands State Park
Millerton Lake State Recreation Area
Mono Lake Tufa State Natural Reserve
Montana de Oro State Park
Montara State Beach
Monterey State Beach
Monterey State Historic Park
Montgomery Woods State Natural Reserve
Moonlight State Beach
Morro Bay State Park
Morro Strand State Beach
Moss Landing State Beach
Mount Diablo State Park
Mount Tamalpais State Park
Natural Bridges State Beach
Navarro River Redwoods State Park
New Brighton State Beach
Oceano Dunes State Vehicular Recreation Area
Ocotillo Wells State Vehicular Recreation Area
Old Sacramento State Historic Park
Old Town San Diego State Historic Park
Olompali State Historic Park
Pacheco State Park
Pacifica State Beach
Palomar Mountain State Park
Sue-meg State Park
Pelican State Beach
Pescadero State Beach
Petaluma Adobe State Historic Park
Picacho State Recreation Area
Pigeon Point Light Station State Historic Park
Pio Pico State Historic Park
Pismo State Beach
Placerita Canyon State Park
Plumas Eureka State Park
Point Dume State Beach
Ishxenta State Park
Point Lobos State Natural Reserve
Point Montara Light Station
Point Mugu State Park
Point Sal State Beach
Point Sur State Historic Park
Pomponio State Beach
Portola Redwoods State Park
Prairie City State Vehicular Recreation Area
Prairie Creek Redwoods State Park
Providence Mountains State Recreation Area
Railtown 1897 State Historic Park
Red Rock Canyon State Park
Refugio State Beach
Reynolds Wayside Campground
Richardson Grove State Park
Rio de LA State Park State Recreation Area
Robert H Meyer Memorial State Beach
Robert Louis Stevenson State Park
Robert W Crown Memorial State Beach
Russian Gulch State Park
Saddleback Butte State Park
Salinas River State Beach
Salt Point State Park
Salton Sea State Recreation Area
Samuel P Taylor State Park
San Bruno Mountain State Park
San Buenaventura State Beach
San Clemente State Beach
San Elijo State Beach
San Gregorio State Beach
San Juan Bautista State Historic Park
San Luis Reservoir State Recreation Area
San Onofre State Beach
San Pasqual Battlefield State Historic Park
San Timoteo Canyon Park Property
Santa Cruz Mission State Historic Park
Santa Monica State Beach
Santa Susana Pass State Historic Park
Schooner Gulch State Beach
Seacliff State Beach
Shasta State Historic Park
Silver Strand State Beach
Silverwood Lake State Recreation Area
Sinkyone Wilderness State Park
Smithe Redwoods State Natural Reserve
Sonoma Coast State Park
Sonoma State Historic Park
South Carlsbad State Beach
South Yuba River State Park
Standish Hickey State Recreation Area
State Indian Museum State Historic Park
Stone Lake Park Property
Sugarloaf Ridge State Park
Sunset State Beach
Sutter Buttes State Park
Tahoe State Recreation Area
The Forest of Nisene Marks State Park
Thornton State Beach
Tijuana Estuary NP Point of Interest
Tolowa Dunes State Park
Tomales Bay State Park
Topanga State Park
Torrey Pines State Beach
Torrey Pines State Natural Reserve
Trinidad State Beach
Tule Elk State Natural Reserve
Turlock Lake State Recreation Area
Twin Lakes State Beach
Van Damme State Park
Verdugo Mountains Park Property
Ward Creek Park Property
Washoe Meadows State Park
Wassama Round House State Historic Park
Watts Towers of Simon Rodia
Weaverville Joss House State Historic Park
Westport Union Landing State Beach
Wilder Ranch State Park
Wildwood Canyon Park Property
Will Rogers State Beach
Will Rogers State Historic Park
Woodland Opera House State Historic Park
Woodson Bridge State Recreation Area
Zmudowski State Beach
Mount San Jacinto State Park
Kenneth Hahn State Recreation Area - Baldwin Hills Scenic Overlook
Long Beach Marine Stadium
Eastern Kern County Onyx Ranch State Vehicular Recreation Area
Locke Boarding House Museum Point of Interest
Santa Ines Mission Mill
Heilbron Mansion
Dos Rios
El Presidio de Santa Barbara State Historic Park
Governor's Mansion State Historic Park
Los Encinos State Historic Park
Point Cabrillo Light Station State Historic Park
Sutter's Fort State Historic Park
William B. Ide Adobe State Historic Park
Tomo-Kahni State Historic Park
Marsh Creek State Park
Pfeiffer Big Sur State Park""".strip().splitlines()

SESSION = requests.Session()
SESSION.headers.update({
    "User-Agent": "CaliforniaParksImageScraper/2.1 (educational; polite; respects rate limits)"
})


def sanitize_filename(name):
    return re.sub(r"\s+", "_", re.sub(r"[^\w\s-]", "", name).strip())


def extract_short_name(park_name):
    for suffix in [
        "State Recreation Area", "State Historic Park", "State Natural Reserve",
        "State Vehicular Recreation Area", "State Beach", "State Park",
        "State Marine Reserve", "State Marine Park", "State Historical Monument",
        "Park Property", "Point of Interest", "Light Station", "Sea Shore",
    ]:
        if park_name.endswith(suffix):
            short = park_name[:-len(suffix)].strip()
            return re.sub(r"\s+State$", "", short).strip() or park_name
    return park_name


def search_commons(park_name):
    api = "https://commons.wikimedia.org/w/api.php"
    for query in [f'"{park_name}"', f"{park_name} California",
                  f"{extract_short_name(park_name)} California park"]:
        try:
            resp = SESSION.get(api, params={
                "action": "query", "generator": "search", "gsrnamespace": 6,
                "gsrsearch": query, "gsrlimit": 5, "prop": "imageinfo",
                "iiprop": "url|mime|size", "iiurlwidth": IMAGE_WIDTH, "format": "json",
            }, timeout=TIMEOUT)
            for page in sorted(resp.json().get("query", {}).get("pages", {}).values(),
                               key=lambda p: p.get("index", 999)):
                info = page.get("imageinfo", [{}])[0]
                if "image" in info.get("mime", "") and info.get("size", 0) > MIN_IMAGE_BYTES:
                    return info.get("thumburl") or info.get("url")
        except Exception:
            pass
    return None


def search_wikipedia_thumb(park_name):
    api = "https://en.wikipedia.org/w/api.php"
    for query in [park_name, f"{park_name} California",
                  f"{extract_short_name(park_name)} California state park"]:
        try:
            resp = SESSION.get(api, params={
                "action": "query", "generator": "search", "gsrsearch": query,
                "gsrlimit": 3, "prop": "pageimages", "piprop": "thumbnail",
                "pithumbsize": IMAGE_WIDTH, "format": "json",
            }, timeout=TIMEOUT)
            for page in sorted(resp.json().get("query", {}).get("pages", {}).values(),
                               key=lambda p: p.get("index", 999)):
                src = page.get("thumbnail", {}).get("source")
                if src:
                    return src
        except Exception:
            pass
    return None


def search_wikipedia_page_images(park_name):
    api = "https://en.wikipedia.org/w/api.php"
    try:
        resp = SESSION.get(api, params={
            "action": "query", "generator": "search",
            "gsrsearch": f"{park_name} California", "gsrlimit": 1, "format": "json",
        }, timeout=TIMEOUT)
        pages = resp.json().get("query", {}).get("pages", {})
        if not pages:
            return None
        page_title = list(pages.values())[0].get("title", "")
    except Exception:
        return None

    skip = ["icon", "logo", "map", "flag", "symbol", ".svg", "commons-logo",
            "wikidata", "edit-clear", "question_book", "ambox", "padlock",
            "wikimedia", "crystal_clear", "folder_hexagonal", "nuvola",
            "disambig", "stub", "portal", "increase", "decrease"]
    try:
        resp = SESSION.get(api, params={
            "action": "query", "titles": page_title,
            "prop": "images", "imlimit": 10, "format": "json",
        }, timeout=TIMEOUT)
        for page in resp.json().get("query", {}).get("pages", {}).values():
            for img in page.get("images", []):
                title = img.get("title", "")
                lower = title.lower()
                if any(s in lower for s in skip):
                    continue
                if not any(ext in lower for ext in [".jpg", ".jpeg", ".png"]):
                    continue
                ir = SESSION.get(api, params={
                    "action": "query", "titles": title, "prop": "imageinfo",
                    "iiprop": "url|size", "iiurlwidth": IMAGE_WIDTH, "format": "json",
                }, timeout=TIMEOUT)
                for ip in ir.json().get("query", {}).get("pages", {}).values():
                    info = ip.get("imageinfo", [{}])[0]
                    if info.get("size", 0) > MIN_IMAGE_BYTES:
                        return info.get("thumburl") or info.get("url")
    except Exception:
        pass
    return None


def search_inaturalist(park_name):
    try:
        resp = SESSION.get("https://api.inaturalist.org/v1/observations", params={
            "q": f"{extract_short_name(park_name)} California",
            "photos": "true", "quality_grade": "research",
            "per_page": 5, "order_by": "votes",
        }, timeout=TIMEOUT)
        for obs in resp.json().get("results", []):
            photos = obs.get("photos", [])
            if photos:
                url = photos[0].get("url", "").replace("square", "medium")
                if url:
                    return url
    except Exception:
        pass
    return None


def download_image(url, filepath):
    try:
        resp = SESSION.get(url, timeout=30, stream=True)
        resp.raise_for_status()
        ct = resp.headers.get("Content-Type", "")
        if "image" not in ct and "octet-stream" not in ct:
            return False
        with open(filepath, "wb") as f:
            for chunk in resp.iter_content(8192):
                f.write(chunk)
        if os.path.getsize(filepath) < MIN_IMAGE_BYTES:
            os.remove(filepath)
            return False
        return True
    except Exception:
        if os.path.exists(filepath):
            os.remove(filepath)
        return False


def convert_to_jpg(filepath):
    try:
        from PIL import Image
        img = Image.open(filepath)
        if img.mode in ("RGBA", "P", "LA"):
            img = img.convert("RGB")
        img.save(filepath, "JPEG", quality=85)
    except ImportError:
        pass


SOURCES = [
    ("commons",       search_commons),
    ("wikipedia",     search_wikipedia_thumb),
    ("wiki_page_img", search_wikipedia_page_images),
    ("inaturalist",   search_inaturalist),
]


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    log_path = os.path.join(OUTPUT_DIR, "scrape_log.csv")
    total = len(PARKS)

    print("=" * 60)
    print("  CA State Parks Image Scraper v2.1 (no API keys)")
    print("=" * 60)
    print(f"  Parks:   {total}")
    print(f"  Output:  {os.path.abspath(OUTPUT_DIR)}/")
    print(f"  Sources: {', '.join(n for n, _ in SOURCES)}")
    print("=" * 60)

    results = []
    for i, park in enumerate(PARKS, 1):
        park = park.strip()
        if not park:
            continue
        fname = sanitize_filename(park) + ".jpg"
        fpath = os.path.join(OUTPUT_DIR, fname)

        if os.path.exists(fpath) and os.path.getsize(fpath) > MIN_IMAGE_BYTES:
            print(f"[{i:3d}/{total}] SKIP: {park}")
            results.append((park, fname, "skipped_exists", "", ""))
            continue

        print(f"[{i:3d}/{total}] {park}")
        found = False
        for source_name, source_fn in SOURCES:
            print(f"         {source_name}...", end=" ", flush=True)
            try:
                url = source_fn(park)
            except Exception as e:
                print(f"error ({e})")
                continue
            if not url:
                print("miss")
                continue
            if download_image(url, fpath):
                convert_to_jpg(fpath)
                print(f"OK ({os.path.getsize(fpath)/1024:.0f} KB)")
                results.append((park, fname, "success", source_name, url))
                found = True
                break
            else:
                print("download failed")

        if not found:
            print(f"         *** NO IMAGE ***")
            results.append((park, "", "not_found", "", ""))
        time.sleep(DELAY)

    with open(log_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["park_name", "filename", "status", "source", "image_url"])
        writer.writerows(results)

    success = sum(1 for r in results if r[2] == "success")
    skipped = sum(1 for r in results if r[2] == "skipped_exists")
    failed  = sum(1 for r in results if r[2] in ("not_found", "download_failed"))
    source_counts = {}
    for r in results:
        if r[2] == "success":
            source_counts[r[3]] = source_counts.get(r[3], 0) + 1

    print("\n" + "=" * 60)
    print(f"  Downloaded: {success}  |  Skipped: {skipped}  |  Failed: {failed}")
    if source_counts:
        print("  By source: " + ", ".join(
            f"{s}={c}" for s, c in sorted(source_counts.items(), key=lambda x: -x[1])))
    if failed:
        print(f"\n  Missing ({failed}):")
        for r in results:
            if r[2] in ("not_found", "download_failed"):
                print(f"    - {r[0]}")
    print(f"\n  Log: {log_path}")
    print("=" * 60)


if __name__ == "__main__":
    main()