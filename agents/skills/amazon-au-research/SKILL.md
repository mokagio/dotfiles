---
name: amazon-au-research
description: |
  Research products on amazon.com.au (Australia) and return options with title-verified links, indicative AUD prices, and stock status.
  Use when asked to research a product, "find me options for X", compare prices, or for help shopping or buying something on Amazon.
  Australian marketplace only — this skill does not cover amazon.com or other marketplaces.
allowed-tools: Bash(curl *), Bash(python3 *), Bash(sleep *), Read
user-invocable: true
---

# Amazon AU product research

Produce a short, verified shortlist of products on **amazon.com.au**.
Every link you hand back must be one you resolved to a real AU product title yourself.

## Why this skill exists

Four failure modes make the obvious approaches produce confidently wrong answers:

1. **Web search cannot source AU links.**
   Search engines return `amazon.com` results almost exclusively, even when the query names `amazon.com.au` explicitly.
   Do not use web search to find product links. Scrape the AU search page instead.
2. **ASINs are not portable between marketplaces.**
   A `/dp/<ASIN>` that works on `amazon.com` usually does not exist on `amazon.com.au`.
   Measured: of 3 US ASINs, 1 existed on AU — and it was a *different variant* of the product.
   Never translate a `.com` link into a `.com.au` link by swapping the domain.
3. **WebFetch is 503'd by Amazon.** Use `curl` with a browser User-Agent and an `Accept-Language: en-AU,en` header.
4. **HTTP 200 does not mean the product exists.**
   Amazon serves 200 for placeholder pages. The `<title>` is the only reliable existence check.

## Workflow

### 1. Find real ASINs from the AU search page

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
curl -s -A "$UA" -H "Accept-Language: en-AU,en" --max-time 30 \
  "https://www.amazon.com.au/s?k=tech+pouch" \
  | python3 -c 'import sys,re; h=sys.stdin.read(); seen=[]; [seen.append(a) for a in re.findall(r"data-asin=\"([A-Z0-9]{10})\"",h) if a not in seen]; print("\n".join(seen[:15]))'
```

URL-encode the query (spaces as `+`).
Run two or three differently-phrased searches when the brief is loose — one query's top hits are not a survey.

### 2. Resolve each ASIN to a title, price, and stock

`resolve_asin.py` sits next to this file. Pipe a product page into it:

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
SKILL_DIR="$HOME/.agents/skills/amazon-au-research"   # or ~/.claude/skills/amazon-au-research
for A in B0FCVLH4XS B0DPQPGXBK; do
  curl -s -A "$UA" -H "Accept-Language: en-AU,en" --max-time 30 "https://www.amazon.com.au/dp/$A" \
    | python3 "$SKILL_DIR/resolve_asin.py" "$A"
  sleep 2
done
```

Output is TSV: `ASIN <tab> price <tab> stock <tab> title`, e.g.

```
B0FCVLH4XS	$99.00	Only 4 left in stock.	OrbitKey 2-in-1 Tech Pouch (Olive)
B0CZ4ZZZZZ	INVALID	Page Not Found
```

**Discard every `INVALID` row.** Never include one in the output, and never report a link you did not resolve.
Keep the `sleep 2` — this is human browsing volume, not a crawl.

Amazon throttles bursts, and a throttled response yields a blank or partial row rather than an error.
If a row comes back empty or a batch that previously worked starts failing, wait and retry that ASIN before concluding it is invalid — `sleep 3` between requests clears it.
A single `INVALID` amid otherwise good rows is trustworthy; a run of them means you are being throttled, not that the products vanished.

If you are writing throwaway extraction code rather than using the script, note that **Python f-strings cannot contain backslash-escaped quotes**.
Use `%`-formatting or `.format()`; an f-string with `\"` inside is a syntax error.

### 3. Judge the candidates

Resolve more ASINs than you need (8–12 for a shortlist of 3) and pick on fit, not on search rank.
Search order reflects Amazon's advertising and sales signals, not the user's brief.
Read the titles for the attributes the brief actually asked about — size, material, capacity, compatibility.

## Output contract

Return **N options (default 3)**, each with:

- Product title.
- A `/dp/<ASIN>` link on `www.amazon.com.au` that you **title-verified** in step 2.
- Indicative price in AUD.
- Stock status.
- One line on why it fits the brief.

Then:

- **An explicit recommendation** — name one, say why.
- **Honest flagging of what the products do not solve.** If nothing found meets part of the brief, say so plainly rather than stretching a product to fit.

### Prices are approximate

Several dollar figures appear in a product page's HTML (list price, deal price, variant prices, subscription prices).
The scraped figure is a reasonable indication, not a quote.
Always label prices as indicative and tell the user to confirm on the page — especially before recommending on price grounds.

## Caveats to state, not bury

- Scraping is against Amazon's ToS. Fine at human browsing volume; do not build anything that hammers it. Expect selectors to break — if extraction returns empty, the markup changed.
- The official APIs are not a viable alternative. PA-API 5.0 was deprecated 15 May 2026 and stopped accepting new signups; its replacement, the Creators API, requires an active Associates account with roughly 10 qualifying sales per rolling 30 days. If price *history* matters, Keepa (paid) is the only decent option.
