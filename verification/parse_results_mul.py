"""
parse_results_mul.py
=====================
Ban parse_results.py rieng cho bo NHAN, vi dong log cua tb_fp_mul_*.v
KHONG co truong OP= (bo cong moi co, vi co add/sub), khac dinh dang voi
parse_results.py goc (danh cho add_sub).
 
Dinh dang moi dong log ($fdisplay trong tb_fp_mul_*.v):
    VEC <idx> <category> <PASS|FAIL> A=<hex8> B=<hex8> EXP=<hex8> GOT=<hex8>
 
Cach dung:
    python parse_results_mul.py results_mul_nopipe.log
    python parse_results_mul.py results_mul_nopipe.log results_mul_pipe2.log results_mul_pipe3.log
"""
 
import sys
import re
from collections import defaultdict
 
LINE_RE = re.compile(
    r"VEC\s+(\d+)\s+(\S+)\s+(PASS|FAIL)\s+A=([0-9A-Fa-f]+)\s+B=([0-9A-Fa-f]+)"
    r"\s+EXP=([0-9A-Fa-f]+)\s+GOT=([0-9A-Fa-f]+)"
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
            idx, cat, status, A, B, exp, got = m.groups()
            total += 1
            by_cat[cat][1] += 1
            if status == "PASS":
                passed += 1
                by_cat[cat][0] += 1
            else:
                fails.append((idx, cat, A, B, exp, got))
 
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
        print(f"  {'idx':<6}{'category':<20}{'A':<10}{'B':<10}{'EXP':<10}{'GOT':<10}")
        for idx, cat, A, B, exp, got in fails[:20]:
            print(f"  {idx:<6}{cat:<20}{A:<10}{B:<10}{exp:<10}{got:<10}")
        if len(fails) > 20:
            print(f"  ... va {len(fails) - 20} vector FAIL khac.")
    print()
    return total, passed, fails
 
 
def main():
    if len(sys.argv) < 2:
        print("Cach dung: python parse_results_mul.py <log1> [log2] [log3] ...")
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