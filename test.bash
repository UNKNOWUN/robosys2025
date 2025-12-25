#!/bin/bash
# SPDX-FileCopyrightText: 2025 Toshiaki Ko <s24c1050qg@s.chibakoudai.jp>

set -eu

chmod +x ./shaft ./shafth
test -f ./materials.csv

# ---------
# Helpers
# ---------
assert_fail() {
  # usage: assert_fail "command..."
  if eval "$@" > /dev/null 2>/dev/null; then
    echo "expected failure but succeeded: $*" >&2
    exit 1
  fi
}

assert_line_count() {
  # usage: assert_line_count file expected
  local file="$1"
  local n="$2"
  local got
  got="$(wc -l < "$file")"
  if [ "$got" -ne "$n" ]; then
    echo "line count mismatch: $file expected=$n got=$got" >&2
    exit 1
  fi
}

# ---------
# Test data
# ---------
cat > /tmp/cases_ok.csv << 'EOF'
case1,50000,30000
case2,0,80000
EOF

# includes comments/blank lines
cat > /tmp/cases_misc.csv << 'EOF'
# comment
case1,50000,30000

case2,0,80000
EOF

# bad rows
cat > /tmp/cases_bad.csv << 'EOF'
case1,50000,30000
bad_missing_cols,123
bad_nonnumeric,abc,10
EOF

# ---------
# Happy path: shaft
# ---------
./shaft 10 a6061 < /tmp/cases_ok.csv > /tmp/out_shaft_ok.csv
assert_line_count /tmp/out_shaft_ok.csv 2
# no header line (first column should be "case1")
grep -q '^case1,' /tmp/out_shaft_ok.csv

# comments/blank lines ignored
./shaft 10 a6061 < /tmp/cases_misc.csv > /tmp/out_shaft_misc.csv
assert_line_count /tmp/out_shaft_misc.csv 2

# deterministic: running twice should match
./shaft 10 a6061 < /tmp/cases_ok.csv > /tmp/out_shaft_ok2.csv
diff -u /tmp/out_shaft_ok.csv /tmp/out_shaft_ok2.csv > /dev/null

# ---------
# Happy path: shafth
# ---------
./shafth 10 6 a6061 < /tmp/cases_ok.csv > /tmp/out_shafth_ok.csv
assert_line_count /tmp/out_shafth_ok.csv 2
grep -q '^case1,' /tmp/out_shafth_ok.csv

./shafth 10 6 a6061 < /tmp/cases_misc.csv > /tmp/out_shafth_misc.csv
assert_line_count /tmp/out_shafth_misc.csv 2

# ---------
# Physics sanity: hollow should be weaker than solid for same do (di>0)
# i.e., sigma_vm should be larger for shafth than shaft, using same do as d
# Compare case1 sigma_vm (6th column for shaft, 7th for shafth)
# shaft columns: name,id,d,sigma_b,tau,sigma_vm,allow,sf  -> sigma_vm = col6
# shafth columns: name,id,do,di,sigma_b,tau,sigma_vm,allow,sf -> sigma_vm = col7
shaft_vm="$(awk -F, 'NR==1{print $6}' /tmp/out_shaft_ok.csv)"
shafth_vm="$(awk -F, 'NR==1{print $7}' /tmp/out_shafth_ok.csv)"
# numeric compare via awk
awk -v a="$shaft_vm" -v b="$shafth_vm" 'BEGIN{exit !(b>a)}' || {
  echo "expected shafth sigma_vm > shaft sigma_vm, got shaft=$shaft_vm shafth=$shafth_vm" >&2
  exit 1
}

# ---------
# Argument validation should fail
# ---------
assert_fail "./shaft 0 a6061 < /tmp/cases_ok.csv"
assert_fail "./shaft -1 a6061 < /tmp/cases_ok.csv"
assert_fail "./shaft 10 NO_SUCH_ID < /tmp/cases_ok.csv"

assert_fail "./shafth 0 0 a6061 < /tmp/cases_ok.csv"
assert_fail "./shafth 10 -1 a6061 < /tmp/cases_ok.csv"
assert_fail "./shafth 10 10 a6061 < /tmp/cases_ok.csv"
assert_fail "./shafth 10 12 a6061 < /tmp/cases_ok.csv"
assert_fail "./shafth 10 6 NO_SUCH_ID < /tmp/cases_ok.csv"

# ---------
# Input validation: bad rows -> nonzero exit
# (should still process valid rows, but exit code must be 2)
# ---------
set +e
./shaft 10 a6061 < /tmp/cases_bad.csv > /tmp/out_shaft_bad.csv 2>/tmp/err_shaft_bad.txt
code=$?
set -e
if [ "$code" -eq 0 ]; then
  echo "expected nonzero exit for bad input rows (shaft)" >&2
  exit 1
fi
# should have at least the first valid line
grep -q '^case1,' /tmp/out_shaft_bad.csv
# errors should be on stderr
grep -q 'error: line' /tmp/err_shaft_bad.txt

set +e
./shafth 10 6 a6061 < /tmp/cases_bad.csv > /tmp/out_shafth_bad.csv 2>/tmp/err_shafth_bad.txt
code=$?
set -e
if [ "$code" -eq 0 ]; then
  echo "expected nonzero exit for bad input rows (shafth)" >&2
  exit 1
fi
grep -q '^case1,' /tmp/out_shafth_bad.csv
grep -q 'error: line' /tmp/err_shafth_bad.txt

echo "OK"
