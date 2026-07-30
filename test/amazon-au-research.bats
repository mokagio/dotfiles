#!/usr/bin/env bats

# Tests for agents/skills/amazon-au-research/resolve_asin.py
#
# Strategy: pipe fixture HTML built from real amazon.com.au markup into the
# script and assert the TSV row. The availability fixtures reproduce the two
# page layouts observed in the wild — one that ships a real <div
# id="availability"> block and one that ships only the csa wrapper.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/agents/skills/amazon-au-research/resolve_asin.py"

# The csa wrapper carries data-csa-c-content-id="availability" and holds nothing
# but a <style> rule. Every fixture includes it, because every real page does.
csa_wrapper() {
  cat <<'HTML'
<div id="availability_feature_div" class="celwidget" data-feature-name="availability"
     data-csa-c-type="widget" data-csa-c-content-id="availability"
     data-csa-c-slot-id="availability_feature_div" data-csa-c-asin="">
  <style>
    .availabilityMoreDetailsIcon {
        width: 12px;
        vertical-align: baseline;
        fill: #969696;
    }
  </style>
</div>
HTML
}

# --- availability ---

@test "the csa wrapper does not masquerade as the availability block" {
  {
    echo '<title>Balega Silver Mini Crew : Amazon.com.au: Clothing</title>'
    csa_wrapper
    echo '<div id="availability" class="a-section"><span class="a-color-success"> In stock </span><br/></div>'
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B0CGDN5QDZ < '$BATS_TEST_TMPDIR/in.html' | cut -f3"
  [ "$status" -eq 0 ]
  [ "$output" = "In stock" ]
}

@test "a CSS artifact never reaches the stock column" {
  {
    echo '<title>Balega Silver Mini Crew : Amazon.com.au: Clothing</title>'
    csa_wrapper
    echo '<div id="availability" class="a-section"><span> In stock </span></div>'
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B0CGDN5QDZ < '$BATS_TEST_TMPDIR/in.html'"
  [[ "$output" != *"availabilityMoreDetailsIcon"* ]]
  [[ "$output" != *"width: 12px"* ]]
}

@test "low-stock wording survives verbatim" {
  {
    echo '<title>FitsT4 Neoprene Water Socks : Amazon.com.au: Sports</title>'
    csa_wrapper
    echo '<div id="availability" class="a-section"><span>Only 1 left in stock.</span></div>'
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B07T1GKM7V < '$BATS_TEST_TMPDIR/in.html' | cut -f3"
  [ "$output" = "Only 1 left in stock." ]
}

@test "a page with no real availability block reports unknown, not a guess" {
  # Observed on B07VGX52C7 (Salomon Adv Hydra Vest 4): the block is absent and
  # the only "In stock" on the page belongs to the frequently-bought-together
  # widget, which describes a different ASIN.
  {
    echo '<title>Salomon Adv Hydra Vest 4 : Amazon.com.au: Sports</title>'
    csa_wrapper
    echo '<div class="_p13n-desktop-sims-fbt_fbt-desktop_shipping-info-show-box__17yWM">'
    echo '<div class="a-row"><span class="a-color-attainable">In stock</span></div></div>'
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B07VGX52C7 < '$BATS_TEST_TMPDIR/in.html' | cut -f3"
  [ "$output" = "unknown" ]
}

@test "inline script JSON does not bleed into the stock column" {
  {
    echo '<title>Some Product : Amazon.com.au: Sports</title>'
    csa_wrapper
    printf '%s\n' '<div id="availability" class="a-section">In stock <script>var x = {"currentlyUnavailableMessage":"Currently unavailable."};</script></div>'
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B000000001 < '$BATS_TEST_TMPDIR/in.html' | cut -f3"
  [ "$output" = "In stock" ]
}

# --- existence check ---

@test "a Page Not Found title is reported INVALID" {
  echo '<title>Page Not Found</title>' > "$BATS_TEST_TMPDIR/in.html"
  run bash -c "python3 '$SCRIPT' B0CZ4ZZZZZ < '$BATS_TEST_TMPDIR/in.html'"
  [[ "$output" == "B0CZ4ZZZZZ	INVALID	"* ]]
}

@test "a placeholder title ending in the ASIN is reported INVALID" {
  echo '<title>widget-B0CZ4ZZZZZ</title>' > "$BATS_TEST_TMPDIR/in.html"
  run bash -c "python3 '$SCRIPT' B0CZ4ZZZZZ < '$BATS_TEST_TMPDIR/in.html'"
  [[ "$output" == *"INVALID"* ]]
}

# --- price ---

@test "displayPrice wins over the a-price-whole fallback" {
  {
    echo '<title>Some Product : Amazon.com.au: Sports</title>'
    echo '<script>{"displayPrice":"$39.95"}</script>'
    echo '<span class="a-price-whole">56</span>'
    csa_wrapper
    echo '<div id="availability" class="a-section">In stock</div>'
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B000000002 < '$BATS_TEST_TMPDIR/in.html' | cut -f2"
  [ "$output" = "\$39.95" ]
}

@test "the a-price-whole fallback drops cents, so it reads as a whole dollar" {
  {
    echo '<title>Some Product : Amazon.com.au: Sports</title>'
    echo '<span class="a-price-whole">129</span>'
    csa_wrapper
  } > "$BATS_TEST_TMPDIR/in.html"

  run bash -c "python3 '$SCRIPT' B000000003 < '$BATS_TEST_TMPDIR/in.html' | cut -f2"
  [ "$output" = "\$129" ]
}
