# robosys2025 — Shaft Section Tools

[![CI](https://github.com/UNKNOWUN/robosys2025/actions/workflows/test.yml/badge.svg)](https://github.com/UNKNOWUN/robosys2025/actions/workflows/test.yml)
![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)
![Python 3.8–3.12](https://img.shields.io/badge/python-3.8%E2%80%933.12-blue)

STEP ファイルから丸シャフト（中実・中空・段付き）の **極断面係数 Zp** と
**極二次モーメント Jp** を数値的に求めるコマンド群です。

また、ねじり荷重の計算を行う `torsionload` も含まれています。
すべてのコマンドは **標準入力・標準出力・標準エラー出力を正しく扱う形** で実装しています。

---

## 目次

* [概要](#概要)
* [構成](#構成)
* [インストール方法](#インストール方法)
* [使い方](#使い方)

  * [torsionload](#torsionload)
  * [step_zp](#step_zp)
  * [step_hollow_zp](#step_hollow_zp)
  * [step_stepped_zp](#step_stepped_zp)
* [計算アルゴリズム](#計算アルゴリズム)
* [参考文献](#参考文献)
* [License](#license)

---

## 概要

* STEP ファイル（`.step`）からシャフト断面を切り出し、数値的に Jp / Zp を計算
* 中実シャフト / 中空シャフト / 段付きシャフトに対応
* 単体コマンドとして UNIX パイプラインに組み込みやすい設計
* GitHub Actions 上で Python 3.8〜3.12 の自動テストを実行

---

## 構成

```text
robosys2025/
├── src/
│   ├── torsionload          # ねじり荷重 T を計算
│   ├── step_zp              # 中実シャフトの Jp, Zp, rmax
│   ├── step_hollow_zp       # 中空シャフトの Do, Di, Jp, Zp
│   └── step_stepped_zp      # 段付きシャフトの最小 Zp 位置と値
├── input/
│   └── *.step               # サンプル STEP モデル
├── data/
│   └── material_properties.tsv  # MISUMI ベースの材質データ
├── test.bash                # すべてのコマンドを検証するテスト
├── LICENSE
└── README.md
```

---

## インストール方法

### 必要環境

* Python **3.8 〜 3.12**
* conda（Miniforge 系推奨）
* `occt` / `pythonocc-core`（conda-forge）

### セットアップ手順

```bash
# conda 環境の作成
conda create -n occenv python=3.10
conda activate occenv

# 依存パッケージのインストール
conda install -c conda-forge occt pythonocc-core

# リポジトリ取得
git clone https://github.com/UNKNOWUN/robosys2025
cd robosys2025
```

### テスト

```bash
chmod +x test.bash
./test.bash
```

ローカルと GitHub Actions の両方で、Python 3.8〜3.12 の全バージョンでテストが通ることを確認しています。

---

## 使い方

### torsionload

ねじり荷重 (T) [N·mm] を計算します。
入力は「せん断応力 (\tau) [MPa], 半径 (r) [mm], 極二次モーメント (J_p) [mm^4]」。

```bash
echo "20 100" | ./src/torsionload
#=> 157.07963267948966
```

---

### step_zp

中実丸シャフトの (J_p), (Z_p), 最大距離 (r_{max}) を求めます。

```bash
./src/step_zp input/shaft_d20_L100.step
#=> 14918.9367 1491.8936 10.0
```

---

### step_hollow_zp

中空シャフトの外径 (D_o)、内径 (D_i)、(J_p)、(Z_p) を求めます。

```bash
./src/step_hollow_zp input/shaft_d20_L100_hole10.step
#=> 20.0 10.0 14726.2155 1472.6215
```

---

### step_stepped_zp

段付きシャフトを Z 軸方向に 10 mm ピッチでスライスし、
もっとも (Z_p) が小さい断面（最弱点）の位置と値を出力します。

```bash
./src/step_stepped_zp input/shaft_stepped.step
#=> 25.0 1565.7570
```

---

## 計算アルゴリズム

* STEP 読み込み: `pythonocc-core` による B-Rep 形状のロード
* 断面抽出: `BRepAlgoAPI_Section` で Z = const の平面と交差
* 各エッジを 64 点でサンプリングし、2D ポリゴンとして再構成
* 多角形公式から以下を算出

  * 面積 (A)
  * 重心 ((c_x, c_y))
  * 重心まわりの二次モーメント (I_x, I_y)
* 極二次モーメント

  * (J_p = I_x + I_y)
* 極断面係数

  * (Z_p = J_p / r_{max}) （(r_{max}): 重心からの最大半径）
* 段付きシャフトでは zmin〜zmax を 10 mm 刻みで探索し、
  (Z_p) が最小となる位置を「弱い箇所」として採用

---

## 参考文献

* ねじり荷重計算

  * [https://www.nmri.go.jp/archives/eng/khirata/design/ch05/ch05_01.html](https://www.nmri.go.jp/archives/eng/khirata/design/ch05/ch05_01.html)
* 材質データ（MISUMI）

  * [https://jp.misumi-ec.com/](https://jp.misumi-ec.com/)
* pythonocc-core

  * [https://github.com/tpaviot/pythonocc-core](https://github.com/tpaviot/pythonocc-core)

---

## License

This software is released under the **BSD 3-Clause License**.
See the [LICENSE](./LICENSE) file for details.

---

## 謝辞

本リポジトリは「ロボットシステム学（robosys2025）」の課題として作成しました。
授業で提供されたテスト環境と資料に感謝します。
