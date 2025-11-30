# robosys2025 ― Shaft Section Tools  
STEP ファイルから丸シャフト（中実・中空・段付き）の **極断面係数 Zp** と  
**極二次モーメント Jp** を数値的に求めるコマンド群です。

また、ねじり荷重の計算を行う `torsionload` も含まれています。  
すべてのコマンドは **標準入力・標準出力・標準エラー出力を正しく扱う形**で実装しています。

---

## 📁 構成
robosys2025/
├── src/
│ ├── torsionload
│ ├── step_zp
│ ├── step_hollow_zp
│ └── step_stepped_zp
├── input/
│ └── *.step
├── data/
│ └── material_properties.tsv
├── test.bash
├── LICENSE
└── README.md

---

## 🔧 インストール方法

### 必要環境
- Python **3.8 〜 3.12**
- conda（Miniforge 推奨）
- occt / pythonocc-core（conda-forge）

### セットアップ手順

```bash
$ conda create -n occenv python=3.10
$ conda activate occenv
$ conda install -c conda-forge occt pythonocc-core


リポジトリ取得
$ git clone https://github.com/UNKNOWUN/robosys2025
$ cd robosys2025

🧪 テスト
このリポジトリにはすべてのコマンドを検証する test.bash が付属しています。
$ chmod +x test.bash
$ ./test.bash
GitHub Actions でも Python 3.8〜3.12 の全バージョンで自動テストを実行します。

🚀 コマンドの使い方
1. torsionload
ねじり荷重 T [N·mm] を計算します。
入力は「せん断応力 τ、半径 r、極二次モーメント Jp」。

実行例
$ echo "20 100" | ./src/torsionload
157.07963267948966

2. step_zp
中実丸シャフトの Jp, Zp, 最大距離 rmax を求めます。
$ ./src/step_zp input/shaft_d20_L100.step
14918.9367 1491.8936 10.0

3. step_hollow_zp
中空シャフトの外径・内径・Jp・Zp を求めます。
$ ./src/step_hollow_zp input/shaft_d20_L100_hole10.step
20.0 10.0 14726.2155 1472.6215

4. step_stepped_zp
段付きシャフトを Z 軸方向に 10 mm ピッチでスライスし、
最も Zp が小さい断面（最弱点）を探索します。
$ ./src/step_stepped_zp input/shaft_stepped.step
25.0 1565.7570

📐 計算アルゴリズム（概要）
・STEP 読み込み：pythonocc-core
・断面抽出：BRepAlgoAPI_Section
・各エッジを 64 点でサンプリング
・多角形公式より
    ・面積 A
    ・重心 (cx, cy)
    ・二次モーメント Ix, Iy
・極二次モーメント
        Jp = Ix + Iy
・極断面係数
        Zp = Jp / rmax
段付きシャフトでは zmin → zmax を 10mm 刻みで探索し、
最も Zp が小さい位置を「弱い箇所」として出力します。

📚 参考文献

・ねじり荷重計算
https://www.nmri.go.jp/archives/eng/khirata/design/ch05/ch05_01.html

・材質データ（MISUMI）
https://jp.misumi-ec.com/

・pythonocc-core
https://github.com/tpaviot/pythonocc-core

📜 License
This software is released under the BSD 3-Clause License.
See the LICENSE file for details.

🙏 謝辞
本リポジトリは ロボットシステム学（robosys2025）課題として作成しました。
授業で提供されたテスト環境と資料に感謝します。
