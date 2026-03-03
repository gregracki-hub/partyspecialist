#!/bin/bash
# Generate 50 logo concepts for The Party Specialist via Recraft API
# Uses recraftv3 vector_illustration and recraftv4_vector models alternating

API_KEY="HFjwhcQwLd9Flzc879lohG90hsVFSGKTc4CKcnZ2eKUQtFFqTU3oWei76ahKWsUH"
OUTPUT_DIR="/Users/gregracki/partyspecialist/logos"
METADATA_FILE="/Users/gregracki/partyspecialist/logos/metadata.json"
mkdir -p "$OUTPUT_DIR"

echo "[" > "$METADATA_FILE"

# Logo prompts - 50 carefully designed variations
# Categories: Monogram, Wordmark, Icon+Text, Abstract, Illustrative, Badge/Emblem
declare -a PROMPTS=(
  # --- ELEGANT MONOGRAM (1-8) ---
  "Elegant monogram logo TPS initials in gold on navy background, serif typography, luxury catering brand, minimal clean design"
  "Art deco monogram logo letters T P S intertwined, black and gold, sophisticated event planner branding"
  "Classic monogram TPS in a circular frame, deep burgundy and cream, fine dining catering logo"
  "Modern minimalist monogram TPS, thin gold lines on dark background, premium event brand"
  "Script calligraphy monogram TPS, flowing elegant letterforms, champagne gold color, white background"
  "Geometric monogram TPS, interlocking letters in navy blue, architectural precision, clean vector"
  "Royal crest style monogram TPS with subtle crown element, dark green and gold, refined"
  "Contemporary monogram TPS with negative space, black and white, sophisticated simplicity"

  # --- WORDMARK / LOGOTYPE (9-16) ---
  "Elegant wordmark logo The Party Specialist in refined serif typography, navy blue, minimal clean design"
  "Script wordmark The Party Specialist in flowing calligraphy, gold gradient on dark background"
  "Modern sans-serif wordmark The Party Specialist, letterspaced, charcoal gray, subtle gold accent line"
  "Sophisticated wordmark The Party Specialist with decorative flourish, deep red and cream"
  "Bold contemporary wordmark THE PARTY SPECIALIST in all caps, tight tracking, navy and gold"
  "Handwritten style wordmark The Party Specialist, warm personal feel, dark brown ink, cream background"
  "Two-line wordmark THE PARTY on top SPECIALIST below, elegant serif, forest green and gold"
  "Stylized wordmark The Party Specialist with subtle fork element integrated into the T, black and gold"

  # --- ICON + TEXT COMBINATION (17-28) ---
  "Catering logo with elegant fork and knife crossed above The Party Specialist text, navy and gold"
  "Logo with stylized chef hat icon above The Party Specialist wordmark, clean vector, black and silver"
  "Logo featuring a silver cloche dome with The Party Specialist text below, elegant minimal"
  "Champagne glass icon with sparkles above The Party Specialist text, gold and navy, celebration theme"
  "Wine glass and fork combined icon with The Party Specialist, burgundy and cream, sophisticated"
  "Stylized plate with decorative garnish icon, The Party Specialist below, modern elegant, teal and gold"
  "Abstract flame and fork icon representing culinary passion, The Party Specialist text, warm red and charcoal"
  "Elegant serving tray being carried icon with The Party Specialist, classic butler service feel, black and gold"
  "Herb sprig and whisk crossed icon above The Party Specialist, fresh green and dark gray, farm to table feel"
  "Star and fork combined minimal icon with The Party Specialist, navy and gold, premium quality"
  "Cocktail shaker icon with The Party Specialist text, art deco style, black gold and white"
  "Laurel wreath encircling a small fork icon with The Party Specialist, classic prestige feel, dark green and gold"

  # --- ABSTRACT MARKS (29-36) ---
  "Abstract flowing ribbon shape suggesting celebration and movement, The Party Specialist, purple and gold"
  "Geometric diamond shape containing fork silhouette, The Party Specialist, modern luxury, black and gold"
  "Abstract wave pattern suggesting North Shore coastal setting, The Party Specialist, ocean blue and sand gold"
  "Overlapping circles forming plate and party element, The Party Specialist, warm coral and charcoal"
  "Spiral abstract mark suggesting whisk motion, The Party Specialist, copper and cream"
  "Starburst abstract mark for celebration, The Party Specialist, midnight blue and gold sparkle"
  "Infinity symbol merged with spoon shape, The Party Specialist, suggesting endless possibilities, silver and navy"
  "Abstract confetti scattered elegantly above The Party Specialist text, festive yet refined, multi-jewel-tone"

  # --- BADGE / EMBLEM / CREST (37-44) ---
  "Circular badge logo The Party Specialist EST 1979 with crossed utensils center, navy and gold, premium"
  "Shield crest logo The Party Specialist with chef hat and stars, traditional prestige, burgundy and gold"
  "Oval emblem logo The Party Specialist North Shore Gourmet Caterer, vintage elegant, dark green and cream"
  "Hexagonal badge The Party Specialist with fork and knife icon, modern geometric, charcoal and gold"
  "Stamp style circular logo The Party Specialist LLC Marblehead MA, rustic refined, brown and cream"
  "Art deco badge The Party Specialist with geometric border pattern, black gold and white, 1920s elegance"
  "Pennant ribbon banner style The Party Specialist with small star accents, navy blue and gold"
  "Double circle seal The Party Specialist Gourmet Catering and Events, classic trust mark, deep blue and silver"

  # --- ILLUSTRATIVE / PLAYFUL SOPHISTICATED (45-50) ---
  "Silhouette of an elegant dinner party table setting viewed from above, The Party Specialist text below, gold and black"
  "Watercolor style gourmet dish illustration with The Party Specialist in elegant type, sophisticated food art feel"
  "Minimalist line art of hands raising champagne glasses in toast, The Party Specialist, celebration motif, gold on navy"
  "Architectural line drawing of elegant tent event setup, The Party Specialist below, clean modern, charcoal and gold"
  "Sketched open cookbook with steam rising forming party elements, The Party Specialist, warm inviting, brown and cream"
  "Art nouveau style decorative frame with fork and spoon, The Party Specialist inside, ornate yet clean, forest green and gold"
)

TOTAL=${#PROMPTS[@]}
echo "Generating $TOTAL logos..."

for i in "${!PROMPTS[@]}"; do
  NUM=$((i + 1))
  PROMPT="${PROMPTS[$i]}"

  # Alternate between v3 vector_illustration and v4_vector for variety
  if (( NUM % 2 == 0 )); then
    MODEL="recraftv4_vector"
    STYLE_PARAM=""
  else
    MODEL="recraftv3"
    STYLE_PARAM='"style": "vector_illustration",'
  fi

  echo "[$NUM/$TOTAL] Generating: ${PROMPT:0:60}..."

  RESPONSE=$(curl -s -X POST "https://external.api.recraft.ai/v1/images/generations" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"prompt\": \"$PROMPT\",
      \"model\": \"$MODEL\",
      ${STYLE_PARAM}
      \"n\": 1
    }")

  # Extract URL from response
  URL=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['url'])" 2>/dev/null)
  IMAGE_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['image_id'])" 2>/dev/null)

  if [ -n "$URL" ] && [ "$URL" != "None" ]; then
    # Download the image
    FILENAME=$(printf "logo_%02d.png" $NUM)
    curl -s -o "$OUTPUT_DIR/$FILENAME" "$URL"
    echo "  -> Saved $FILENAME (ID: $IMAGE_ID)"

    # Append to metadata
    COMMA=""
    if [ $NUM -gt 1 ]; then COMMA=","; fi
    echo "${COMMA}{\"num\":$NUM,\"file\":\"$FILENAME\",\"prompt\":\"$(echo "$PROMPT" | sed 's/"/\\"/g')\",\"model\":\"$MODEL\",\"image_id\":\"$IMAGE_ID\",\"url\":\"$URL\"}" >> "$METADATA_FILE"
  else
    echo "  -> FAILED: $RESPONSE"
    COMMA=""
    if [ $NUM -gt 1 ]; then COMMA=","; fi
    echo "${COMMA}{\"num\":$NUM,\"file\":null,\"prompt\":\"$(echo "$PROMPT" | sed 's/"/\\"/g')\",\"error\":\"generation failed\"}" >> "$METADATA_FILE"
  fi

  # Small delay to avoid rate limiting
  sleep 1
done

echo "]" >> "$METADATA_FILE"
echo "Done! All logos in $OUTPUT_DIR"
echo "Metadata in $METADATA_FILE"
