#!/bin/sh

RES_FILE="tf_mvm_missioncycle.res"
BSP_DIR="../../custom_maps/maps"

# -----------------------------
# Extract count (bulletproof)
# -----------------------------
CURRENT_COUNT=$(sed -n '
/"count"[[:space:]]*"/ {
    s/[^0-9]//g
    p
    q
}
' "$RES_FILE")

case "$CURRENT_COUNT" in
    ''|*[!0-9]*)
        echo "Invalid or missing count in $RES_FILE"
        exit 1
        ;;
esac

# -----------------------------
# Extract existing map names
# -----------------------------
EXISTING_MAPS=$(sed -n '
/"map"[[:space:]]*"/ {
    s/.*"map"[[:space:]]*"\([^"]*\)".*/\1/p
}
' "$RES_FILE")

NEW_INDEX=$CURRENT_COUNT
TMP_ENTRIES=$(mktemp) || exit 1
ADDED=0

# -----------------------------
# Iterate BSP files
# -----------------------------
for bsp in "$BSP_DIR"/*.bsp; do
    [ -e "$bsp" ] || continue

    map=$(basename "$bsp" .bsp)

    # Deduplication
    printf '%s\n' "$EXISTING_MAPS" | grep -qx "$map" && continue

    NEW_INDEX=$((NEW_INDEX + 1))
    ADDED=$((ADDED + 1))

    cat >> "$TMP_ENTRIES" <<EOF
                "$NEW_INDEX"
                {
                        "map" "$map"
                        "popfile" "$map"
                }
EOF
done

# -----------------------------
# Nothing to add
# -----------------------------
if [ "$ADDED" -eq 0 ]; then
    rm "$TMP_ENTRIES"
    echo "No new maps to add"
    exit 0
fi

# -----------------------------
# Update count
# -----------------------------
sed -i '
/"count"[[:space:]]*"/ {
    s/"count"[[:space:]]*"[^"]*"/"count" "'"$NEW_INDEX"'"/
}
' "$RES_FILE"

# -----------------------------
# Insert entries before category close
# -----------------------------
sed -i "/^[[:space:]]*}[[:space:]]*$/{
    r $TMP_ENTRIES
    :a
    n
    ba
}" "$RES_FILE"

rm "$TMP_ENTRIES"

echo "Added $ADDED new maps (count now $NEW_INDEX)"
