#!/usr/bin/env bash
# test.bash : robosys2025 のテストスクリプト
# 使い方: リポジトリのトップで
#   chmod +x test.bash
#   ./test.bash

set -u

ng=0

# ------------------------------
# 便利関数: 浮動小数の近さをチェック
#   feq GOT EXPECT TOL
# ------------------------------
feq () {
    python3 - "$1" "$2" "$3" << 'PY'
import sys, math
got, exp, tol = map(float, sys.argv[1:])
sys.exit(0 if abs(got-exp) <= tol else 1)
PY
}

# ==============================
# 1. torsionload のテスト
# ==============================
echo "== test_torsionload =="

# 入力: 半径 20 mm, トルク 100 Nmm くらいの想定（今の実装に合わせてある）
out=$(echo "20 100" | ./src/torsionload)
exp="157.07963267948966"

if [ "$out" = "$exp" ]; then
    echo "[OK] torsionload"
else
    echo "[NG] torsionload: got=${out}, expected=${exp}"
    ng=$((ng + 1))
fi

# ==============================
# 2. step_zp (中実シャフト)
# ==============================
echo "== test_step_zp =="

# 入力モデル: φ20, L=100 の中実シャフト
out=$(./src/step_zp input/shaft_d20_L100.step)
# 出力: "Jp Zp rmax" の 3 つが空白区切りで出てくる前提
Jp=$(echo "$out" | awk '{print $1}')
Zp=$(echo "$out" | awk '{print $2}')
Rmax=$(echo "$out" | awk '{print $3}')

# 今のプログラムが実際に吐いている値を「正」としておく
exp_Jp=14918.936737646043
exp_Zp=1491.893673764604
exp_Rmax=10.000000000000002

tol_Jp=1.0e-6
tol_Zp=1.0e-6
tol_Rmax=1.0e-6

if feq "$Jp" "$exp_Jp" "$tol_Jp"; then
    echo "[OK] step_zp Jp"
else
    echo "[NG] step_zp Jp: got=${Jp}, expected=${exp_Jp}"
    ng=$((ng + 1))
fi

if feq "$Zp" "$exp_Zp" "$tol_Zp"; then
    echo "[OK] step_zp Zp"
else
    echo "[NG] step_zp Zp: got=${Zp}, expected=${exp_Zp}"
    ng=$((ng + 1))
fi

if feq "$Rmax" "$exp_Rmax" "$tol_Rmax"; then
    echo "[OK] step_zp rmax"
else
    echo "[NG] step_zp rmax: got=${Rmax}, expected=${exp_Rmax}"
    ng=$((ng + 1))
fi

# ==============================
# 3. step_hollow_zp (中空シャフト)
# ==============================
echo "== test_step_hollow_zp =="

# 入力モデル: φ20, 内径 φ10, L=100 の中空シャフト
out=$(./src/step_hollow_zp input/shaft_d20_L100_hole10.step)
# 出力: "Do Di Jp Zp" の 4 つ
Do=$(echo "$out" | awk '{print $1}')
Di=$(echo "$out" | awk '{print $2}')
Jp_h=$(echo "$out" | awk '{print $3}')
Zp_h=$(echo "$out" | awk '{print $4}')

exp_Do=20.000000000000004
exp_Di=9.999999999999998
exp_Jp_h=14726.215563702166
exp_Zp_h=1472.6215563702162

tol_D=1.0e-6
tol_Jp_h=1.0e-6
tol_Zp_h=1.0e-6

if feq "$Do" "$exp_Do" "$tol_D"; then
    echo "[OK] step_hollow_zp Do"
else
    echo "[NG] step_hollow_zp Do: got=${Do}, expected=${exp_Do}"
    ng=$((ng + 1))
fi

if feq "$Di" "$exp_Di" "$tol_D"; then
    echo "[OK] step_hollow_zp Di"
else
    echo "[NG] step_hollow_zp Di: got=${Di}, expected=${exp_Di}"
    ng=$((ng + 1))
fi

if feq "$Jp_h" "$exp_Jp_h" "$tol_Jp_h"; then
    echo "[OK] step_hollow_zp Jp"
else
    echo "[NG] step_hollow_zp Jp: got=${Jp_h}, expected=${exp_Jp_h}"
    ng=$((ng + 1))
fi

if feq "$Zp_h" "$exp_Zp_h" "$tol_Zp_h"; then
    echo "[OK] step_hollow_zp Zp"
else
    echo "[NG] step_hollow_zp Zp: got=${Zp_h}, expected=${exp_Zp_h}"
    ng=$((ng + 1))
fi

# ==============================
# 4. step_stepped_zp (段付きシャフト)
# ==============================
echo "== test_step_stepped_zp =="

# 入力モデル: shaft_stepped.step
out=$(./src/step_stepped_zp input/shaft_stepped.step)
# 出力: "z_rel Zp_min"
z_rel=$(echo "$out" | awk '{print $1}')
Zp_s=$(echo "$out" | awk '{print $2}')

# Zp は φ20 部分の値が最小になっているはず
exp_Zp_s=1565.7570222249888
tol_Zp_s=1.0e-6

if feq "$Zp_s" "$exp_Zp_s" "$tol_Zp_s"; then
    echo "[OK] step_stepped_zp Zp_min"
else
    echo "[NG] step_stepped_zp Zp_min: got=${Zp_s}, expected=${exp_Zp_s}"
    ng=$((ng + 1))
fi

# z_rel はモデルをいじると変わるので、ここではチェックしない

# ==============================
# 結果まとめ
# ==============================
if [ "$ng" -eq 0 ]; then
    echo "All tests passed."
    exit 0
else
    echo "${ng} test(s) failed."
    exit 1
fi