# shaft / shafth

曲げおよびねじりを受けるシャフトの強度を計算するコマンドです。

本リポジトリには以下の 2 つのコマンドが含まれています。

* `shaft`  : 中実シャフトの強度計算
* `shafth` : 中空シャフトの強度計算

## 概要

これらのコマンドは、曲げ応力・ねじりせん断応力・von Mises 応力および安全率を計算します。
材料特性はリポジトリ直下の `materials.csv` から読み込み、計算ケースは標準入力から与えます。
許容応力には `materials.csv` の `Sy_MPa` 列を使用します。

## 使用方法

入力は標準入力から与える CSV 形式（ヘッダなし）です。

```
name,M_Nmm,T_Nmm
```

### コマンド

```
./shaft  d_mm        material_id < cases.csv
./shafth do_mm di_mm material_id < cases.csv
```

## 実行例

```
./shaft 10 a6061 < cases.csv
./shafth 10 6 a6061 < cases.csv
```

## 出力

計算結果は標準出力に CSV 形式（ヘッダなし）で出力されます。

* `shaft` 出力列
  ケース名, 材料ID, 直径[mm], 曲げ応力[MPa], ねじりせん断応力[MPa], von Mises 応力[MPa], 許容応力[MPa], 安全率

* `shafth` 出力列
  ケース名, 材料ID, 外径[mm], 内径[mm], 曲げ応力[MPa], ねじりせん断応力[MPa], von Mises 応力[MPa], 許容応力[MPa], 安全率

## テスト環境

* Python 3.8–3.12

## 謝辞

本ソフトウェアの一部は、下記の講義資料を参考にして作成しました。

* [https://ryuichiueda.github.io/slides_marp/robosys2025/](https://ryuichiueda.github.io/slides_marp/robosys2025/)

## ライセンス

* 本ソフトウェアは、3条項BSDライセンスの下で再頒布および使用が許可されます。
* © 2025 Toshiaki Ko
