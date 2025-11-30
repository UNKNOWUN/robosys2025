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
* [前提環境（Requirements）](#前提環境requirements)
* [インストール方法](#インストール方法)
* [使い方](#使い方)

  * [torsionload](#torsionload)
  * [step_zp](#step_zp)
  * [step_hollow_zp](#step_hollow_zp)
  * [step_stepped_zp](#step_stepped_zp)
* [計算アルゴリズム](#計算アルゴリズム)
* [参考文献](#参考文献)
* [使用ライブラリのライセンスについて](#使用ライブラリのライセンスについて)
* [License](#license)
* [謝辞](#謝辞)

---

## 概要

* STEP ファイル（`.step`）からシャフト断面を切り出し、数値的に Jp / Zp を計算
* 中実シャフト / 中空シャフト / 段付きシャフトに対応
* 単体コマンドとして UNIX パイプラインに組み込みやすい設計
* GitHub Actions 上で Python 3.8〜3.12 の自動テストを実行

---

## 構成

```text
obosys2025/
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

## 前提環境

本プロジェクトでは STEP 形式の 3D モデルを扱うため、`pythonocc-core` と `Open Cascade Technology (OCCT)` を使用します。
そのため、以下の環境が必要です。

* Linux（Ubuntu 推奨）
* Python **3.8 – 3.12**
* conda（Miniforge / Mambaforge 推奨）
* OCCT（conda-forge より自動インストール）
* pythonocc-core（conda-forge より自動インストール）

インストール例：

```bash
conda create -n occenv python=3.10
conda activate occenv
conda install -c conda-forge occt pythonocc-core
```

---

## インストール方法

```bash
# リポジトリ取得
git clone https://github.com/UNKNOWUN/robosys2025
cd robosys2025

# テスト
chmod +x test.bash
./test.bash
```

---

## 使い方

### torsionload

ねじり荷重 T [N·mm] を計算します。
入力: せん断応力 τ, 半径 r, 極二次モーメント Jp

```bash
echo "20 100" | ./src/torsionload
#=> 157.07963267948966
```

---

### step_zp

中実シャフトの Jp, Zp, 最大距離 rmax を求めます。

```bash
./src/step_zp input/shaft_d20_L100.step
#=> 14918.9367 1491.8936 10.0
```

---

### step_hollow_zp

中空シャフトの Do, Di, Jp, Zp を計算します。

```bash
./src/step_hollow_zp input/shaft_d20_L100_hole10.step
#=> 20.0 10.0 14726.2155 1472.6215
```

---

### step_stepped_zp

段付きシャフトを 10mm ピッチでスライスし最弱点を探索します。

```bash
./src/step_stepped_zp input/shaft_stepped.step
#=> 25.0 1565.7570
```

---

## 計算アルゴリズム

* STEP 読み込み: pythonocc-core を使用
* 断面抽出: BRepAlgoAPI_Section
* エッジを 64 点サンプリング → ポリゴン化
* 面積 A, 重心 (cx, cy), Ix, Iy を計算
* Jp = Ix + Iy
* Zp = Jp / rmax
* 段付きシャフトは zmin→zmax を 10mm 刻みで探索

---

## 参考文献

* ねじり荷重計算
  [https://www.nmri.go.jp/archives/eng/khirata/design/ch05/ch05_01.html](https://www.nmri.go.jp/archives/eng/khirata/design/ch05/ch05_01.html)
* MISUMI 材質データ
  [https://jp.misumi-ec.com/](https://jp.misumi-ec.com/)
* pythonocc-core
  [https://github.com/tpaviot/pythonocc-core](https://github.com/tpaviot/pythonocc-core)

---

## 使用ライブラリのライセンスについて

本プロジェクトは以下の外部ライブラリを使用しています。

### ● pythonocc-core

* License: LGPL-2.1
* Repository: [https://github.com/tpaviot/pythonocc-core](https://github.com/tpaviot/pythonocc-core)

### ● Open Cascade Technology (OCCT)

* License: LGPL-2.1 with Open Cascade exception
* [https://www.opencascade.com/content/licensing](https://www.opencascade.com/content/licensing)

OCCT の "LGPL + Exception" は非常に緩やかで、
本プロジェクトのようにライブラリを動的利用する場合、
**本プロジェクトを LGPL へ変更する義務はありません。**
そのため本リポジトリは **BSD-3-Clause License** のままで問題ありません。

---

## ライセンス

本ソフトウェアは 3条項BSDライセンス のもとで公開されています。
詳細は [LICENSE](./LICENSE) を参照してください。

© 2025 

---

## 謝辞

本リポジトリは「ロボットシステム学（robosys2025）」課題として作成しました。
本プロジェクトでは以下の技術・資料を利用しました。

* pythonocc-core / Open Cascade Technology (OCCT)
STEP 形状の読み込み・断面抽出に使用。

* GitHub Actions
Python 3.8〜3.12 の自動テストに使用。

* MISUMI 材質データ
材料物性値の参照に使用。

* NMRI 機械設計資料
ねじり荷重の基礎式を参照。
    https://www.nmri.go.jp/archives/eng/khirata/design/ch05/ch05_01.html

* Robosys2025（ロボットシステム学）講義資料
標準入出力、UNIX コマンド設計、GitHub 運用の基礎として利用。

    [ryuichiueda/slides_marp/robosys2025](https://github.com/ryuichiueda/slides_marp/tree/master/robosys2025)

関係する全てのソフトウェア・資料に感謝します。
