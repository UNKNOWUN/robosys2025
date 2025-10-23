#!/usr/bin/python3
# SPDX-FileCopyrightText: 2025 Toshiaki Kou <s24c1050qg@s.chiabakoudai.jp>

import sys

ans = 0.0
for line in sys.stdin:
    try:
        ans += int(line)

    except:
        ans += float(line)

print(ans)
