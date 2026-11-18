#!/usr/bin/env bash
# 編譯 extract_code.py 抽出的每一支範例，有 iosample 的就拿輸入跑，和預期輸出比對。
# 用法：scripts/run_tests.sh build/code
#
# 記憶體：開了 AddressSanitizer 的程式會先保留很大的虛擬位址空間，不能用
# ulimit -v 限制，所以改用 systemd 的 scope 限制實際用量（MemoryMax=4G）。
# make test 已經包好了；直接執行這支腳本時，它也會自己用 systemd-run 重新啟動一次。
set -u
root=${1:?usage: run_tests.sh <code-dir>}
if [ -z "${DSA_MEMCAP:-}" ] && command -v systemd-run > /dev/null 2>&1; then
    exec systemd-run --user --scope --quiet -p MemoryMax=4G \
        env DSA_MEMCAP=1 "$0" "$@"
fi
CC=${CC:-gcc}
CFLAGS="-std=c11 -O2 -Wall -Wextra -fsanitize=address,undefined"
pass=0; fail=0
for src in "$root"/*/*.c; do
    [ -e "$src" ] || continue
    stem=${src%.c}
    name=${src#"$root"/}
    if ! warn=$($CC $CFLAGS "$src" -o "$stem.bin" -lm 2>&1) || [ -n "$warn" ]; then
        echo "FAIL (compile) $name"; echo "$warn" | head -20
        fail=$((fail + 1)); continue
    fi
    if [ -f "$stem.out" ]; then
        if [ -f "$stem.in" ]; then input="$stem.in"; else input=/dev/null; fi
        if ! "$stem.bin" < "$input" > "$stem.actual" 2> "$stem.err"; then
            echo "FAIL (runtime) $name"; head -20 "$stem.err"
            fail=$((fail + 1)); continue
        fi
        if [ -s "$stem.err" ]; then
            echo "FAIL (stderr) $name"; head -20 "$stem.err"
            fail=$((fail + 1)); continue
        fi
        if ! diff -q "$stem.actual" "$stem.out" > /dev/null; then
            echo "FAIL (output) $name"; diff "$stem.actual" "$stem.out" | head -20
            fail=$((fail + 1)); continue
        fi
        echo "ok   $name"
    else
        echo "ok   $name (compile only)"
    fi
    pass=$((pass + 1))
done
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
