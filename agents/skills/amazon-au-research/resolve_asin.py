"""Resolve one amazon.com.au ASIN to title / indicative price / availability.

Usage: curl ... https://www.amazon.com.au/dp/<ASIN> | python3 resolve_asin.py <ASIN>
Prints a TSV row, or "<ASIN>\tINVALID\t<title>" when the ASIN does not exist on the AU marketplace.
"""
import sys, re, html

h = sys.stdin.read()
asin = sys.argv[1]

def strip_tags(s):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", s)).strip()

m = re.search(r"<title[^>]*>(.*?)</title>", h, re.S | re.I)
title = html.unescape(m.group(1)).strip() if m else ""
title = re.split(r"\s*:\s*Amazon\.com\.au", title)[0].strip()

# Amazon serves a 200 for pages that are not real listings, so the title is the
# only reliable existence check. A bare "<something>-<ASIN>" title is a placeholder.
bad = (not title
       or "Page Not Found" in title
       or "Robot Check" in title
       or title.endswith("-" + asin))
if bad:
    print("%s\tINVALID\t%s" % (asin, title or "(no title)"))
    sys.exit(0)

prices = re.findall(r'"displayPrice"\s*:\s*"\$([0-9,]+\.[0-9]{2})"', h)
if not prices:
    prices = re.findall(r'a-price-whole">([0-9,]+)', h)
price = ("$" + prices[0]) if prices else "n/a"

# Only the #availability block is trustworthy; a page-wide "in stock" grep
# false-positives on unrelated markup.
am = re.search(r'<div[^>]*id="availability".*?</div>', h, re.S)
stock = strip_tags(am.group(0)) if am else ""
# Inline <script> JSON can bleed into the block; keep only the leading prose.
stock = stock.split("{")[0].strip()[:60] or "unknown"

print("%s\t%s\t%s\t%s" % (asin, price, stock, title[:100]))
