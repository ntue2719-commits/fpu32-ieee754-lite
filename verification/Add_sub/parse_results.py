"""
parse_results.py
=================
Đọc file log do testbench Verilog xuất ra (định dạng dòng thống nhất, xem
mẫu bên dưới) và in bảng thống kê PASS/FAIL, breakdown theo category,
và danh sách chi tiết các vector FAIL.

Định dạng mỗi dòng log testbench cần xuất ra (đúng theo $fdisplay trong TB):
    VEC <idx> <category> <PASS|FAIL> A=<hex8> B=<hex8> OP=<0|1> EXP=<hex8> GOT=<hex8>

Cách dùng:
    python parse_results.py results_nopipe.log
    python parse_results.py results_3stage.log results_2stage.log results_nopipe.log
"""

import sys
import re
from collections import defaultdict

LINE_RE = re.compile(
    r"VEC\s+(\d+)\s+(\S+)\s+(PASS|FAIL)\s+A=([0-9A-Fa-f]+)\s+B=([0-9A-Fa-f]+)"
    r"\s+OP=(\d)\s+EXP=([0-9A-Fa-f]+)\s+GOT=([0-9A-Fa-f]+)"
)


def parse_log(path):
    total = 0
    passed = 0
    fails = []
    by_cat = defaultdict(lambda: [0, 0])  # category -> [pass, total]

    with open(path, "r") as f:
        for line in f:
            m = LINE_RE.search(line)
            if not m:
                continue
            idx, cat, status, A, B, op, exp, got = m.groups()
            total += 1
            by_cat[cat][1] += 1
            if status == "PASS":
                passed += 1
                by_cat[cat][0] += 1
            else:
                fails.append((idx, cat, A, B, op, exp, got))

    return total, passed, fails, by_cat


def report(path):
    total, passed, fails, by_cat = parse_log(path)
    print("=" * 70)
    print(f"KET QUA: {path}")
    print("=" * 70)
    if total == 0:
        print("  KHONG tim thay dong log hop le nao. Kiem tra lai dinh dang $fdisplay trong TB.")
        return total, passed, fails

    rate = 100.0 * passed / total
    print(f"  Tong so vector : {total}")
    print(f"  PASS           : {passed}")
    print(f"  FAIL           : {total - passed}")
    print(f"  Ty le PASS     : {rate:.2f}%")
    print()
    print("  Breakdown theo category:")
    print(f"  {'Category':<22}{'Pass/Total':<12}{'Ty le':>8}")
    for cat, (p, t) in sorted(by_cat.items()):
        r = 100.0 * p / t if t else 0
        print(f"  {cat:<22}{f'{p}/{t}':<12}{r:>7.1f}%")

    if fails:
        print()
        print(f"  Chi tiet {len(fails)} vector FAIL (toi da hien 20 dong dau):")
        print(f"  {'idx':<6}{'category':<20}{'A':<10}{'B':<10}{'op':<4}{'EXP':<10}{'GOT':<10}")
        for idx, cat, A, B, op, exp, got in fails[:20]:
            print(f"  {idx:<6}{cat:<20}{A:<10}{B:<10}{op:<4}{exp:<10}{got:<10}")
        if len(fails) > 20:
            print(f"  ... va {len(fails) - 20} vector FAIL khac.")
    print()
    return total, passed, fails


def main():
    if len(sys.argv) < 2:
        print("Cach dung: python parse_results.py <log1> [log2] [log3] ...")
        sys.exit(1)

    summary = []
    for path in sys.argv[1:]:
        total, passed, fails = report(path)
        summary.append((path, total, passed))

    if len(summary) > 1:
        print("=" * 70)
        print("SO SANH TONG HOP")
        print("=" * 70)
        print(f"  {'File':<28}{'Total':<8}{'Pass':<8}{'Ty le':>8}")
        for path, total, passed in summary:
            rate = 100.0 * passed / total if total else 0
            print(f"  {path:<28}{total:<8}{passed:<8}{rate:>7.1f}%")


if __name__ == "__main__":
    main()
