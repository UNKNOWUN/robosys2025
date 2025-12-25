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

結果は標準出力に CSV 形式（ヘッダなし）で出力されます。

* `shaft` の出力形式

```
name,material_id,d_mm,sigma_b_MPa,tau_MPa,sigma_vm_MPa,allow_MPa,safety_factor
```

* `shafth` の出力形式

```
name,material_id,do_mm,di_mm,sigma_b_MPa,tau_MPa,sigma_vm_MPa,allow_MPa,safety_factor
```

## テスト環境

テストはシェルスクリプトで記述されており、Python を直接呼び出さずに実行します。

```
bash test/test.bash
```

## 謝辞

本ソフトウェアは、大学のロボットシステム系講義の課題として作成しました。

## 著作権

Copyright (c) 2025 Toshiaki Ko

License: BSD 3-Clause
