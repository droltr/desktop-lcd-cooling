#!/usr/bin/env python3
"""Step 1 smoke test: drive the Zalman LCD through zalman_lcd.LcdClient only.

Shows a test card, cycles brightness and orientation, then leaves the card up.
Usage: .venv/bin/python scripts/lcd-smoke-test.py
"""

import logging
import sys
import time
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "zalman-Alpha2-DS-LCD-Linux"))
from zalman_lcd.client import LcdClient  # noqa: E402
from zalman_lcd.device import find_tty  # noqa: E402

logging.basicConfig(level=logging.DEBUG, format="%(asctime)s %(levelname)s %(message)s")


def test_card(path):
    img = Image.new("RGB", (320, 320), "#102040")
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, 319, 319), outline="white", width=4)
    d.polygon([(160, 20), (140, 60), (180, 60)], fill="yellow")  # "up" marker
    d.text((90, 140), "ZALMAN LCD TEST", fill="white")
    d.text((110, 170), time.strftime("%H:%M:%S"), fill="#7fffd4")
    img.save(path)


def main():
    tty = find_tty()
    print("tty:", tty)
    if tty is None:
        sys.exit("LCD serial port not found")
    card = Path("/tmp") / "zalman-test-card.png"
    test_card(card)
    client = LcdClient()
    try:
        client.set_image(card)
        print("image sent")
        for b in (20, 100, 80):
            client.set_brightness(b)
            print("brightness", b)
            time.sleep(2)
        for o in (90, 180, 270, 0):
            client.set_orientation(o)
            print("orientation", o)
            time.sleep(2)
    finally:
        client.close()
    print("OK")


if __name__ == "__main__":
    main()
