#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PLUGIN=$(cd "$SCRIPT_DIR/.." && pwd)/check_domain_rdap
TEST_ROOT=$(mktemp -d)
MOCK_BIN="$TEST_ROOT/bin"
CACHE_DIR="$TEST_ROOT/cache"

cleanup() {
    [[ -n "${TEST_ROOT:-}" && -d "$TEST_ROOT" ]] && rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

mkdir -p "$MOCK_BIN" "$CACHE_DIR"

cat >"$MOCK_BIN/curl" <<'EOF'
#!/usr/bin/env bash
echo "curl: (22) The requested URL returned error: 404" >&2
exit 22
EOF

cat >"$MOCK_BIN/jq" <<'EOF'
#!/usr/bin/env bash
file="${@: -1}"

case "${1:-}" in
    -e)
        grep -q '"eventAction":"expiration"' "$file" &&
            ! grep -q '"errorCode"' "$file"
        ;;
    -r)
        sed -n 's/.*"eventDate":"\([^"]*\)".*/\1/p' "$file" | head -n 1
        ;;
    *)
        exit 2
        ;;
esac
EOF

cat >"$MOCK_BIN/whois" <<'EOF'
#!/usr/bin/env bash
cat <<'RESPONSE'
Domain Name: GOOGLE.CO
Registry Expiry Date: 2030-02-24T23:59:59.0Z
RESPONSE
EOF

cat >"$MOCK_BIN/timeout" <<'EOF'
#!/usr/bin/env bash
shift
exec "$@"
EOF

cat >"$MOCK_BIN/flock" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

chmod +x "$MOCK_BIN/curl" "$MOCK_BIN/jq" "$MOCK_BIN/whois" "$MOCK_BIN/timeout" "$MOCK_BIN/flock"

set +e
output=$(
    PATH="$MOCK_BIN:$PATH" \
        RDAP_CACHE_DIR="$CACHE_DIR" \
        bash "$PLUGIN" -d google.co -w 30 -c 7 2>&1
)
status=$?
set -e

if ((status != 0)); then
    echo "FAIL - expected .co lookup to return OK (exit 0), got exit $status"
    echo "$output"
    exit 1
fi

if [[ "$output" != "OK - google.co "* ]]; then
    echo "FAIL - expected .co lookup output to start with OK"
    echo "$output"
    exit 1
fi

echo "PASS - .co lookup uses the registry WHOIS expiry date"
