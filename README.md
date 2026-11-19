# 資料結構與演算法：C 語言、虛擬碼與研究所考試

作者：林子祐

「註解 Annotated 演算法系列」的第 4 本，寫給修大學資料結構、演算法必修的學生，以及準備資工所筆試的讀者。 先備是[《C 程式設計基礎》](https://github.com/AkizumiFox/c-programming-book)（網頁版 [annotated.codes/learn/c](https://annotated.codes/learn/c)）：指標、`malloc`、`struct`、遞迴都假設已經會了，用到時用「《C 程式設計基礎》回顧」框簡短複習，並寫出在那本書的第幾章。

每個演算法都有兩種寫法：教科書風格的虛擬碼，用來講道理、算次數、手算追蹤；以及自己用 `malloc` 和指標寫的 C11 程式，不用任何現成的容器，書上印的輸出都實際跑過。 每章依序是觀念、虛擬碼、C 實作、手算追蹤（照筆試寫答案的方式，例如 AVL 每次旋轉後畫一次樹、雜湊的探測序列、每一步的堆積陣列），章末有觀念題（計算、追蹤、證明、選擇，全部自己出，附解答）和 Aki-Judge 上的實作題單（只列題名，不附解答）。

- 各章 PDF：[1](output/chapters/01_Analysis.pdf)
- 網頁版：預計放在 annotated.codes/learn/dsa（還沒上線）
- 原始碼：`src/`（XeLaTeX）

## 章節

章號一開始就定好，還沒寫的章先空著，之後補上時已寫的章不用改號。

| # | 章 | 狀態 |
|---|---|---|
| | **第一部　基礎** | |
| 1 | 演算法分析與漸近符號 | 草稿 |
| 2 | 遞迴式 | 草稿 |
| 3 | 平攤分析 | 草稿 |
| | **第二部　資料結構** | |
| 4 | 陣列、矩陣與多項式 | 規劃中 |
| 5 | 鏈結串列 | 草稿 |
| 6 | 堆疊與佇列 | 草稿 |
| 7 | 樹與二元樹 | 草稿 |
| 8 | 堆積與優先佇列 | 草稿 |
| 9 | 二元搜尋樹 | 草稿 |
| 10 | 平衡搜尋樹：AVL 與紅黑樹 | 草稿 |
| 11 | 多路搜尋樹：2-3 樹、2-3-4 樹、B 樹與 B+ 樹 | 草稿 |
| 12 | 雜湊 | 草稿 |
| 13 | 互斥集合 | 草稿 |
| | **第三部　排序與選擇** | |
| 14 | 排序 | 草稿 |
| 15 | 排序的下界、線性時間排序與外部排序 | 草稿 |
| 16 | 選擇問題 | 草稿 |
| | **第四部　演算法設計** | |
| 17 | 分治 | 草稿 |
| 18 | 動態規劃 | 草稿 |
| 19 | 貪心 | 草稿 |
| 20 | 回溯與分支限界 | 草稿 |
| | **第五部　圖論** | |
| 21 | 圖的表示、BFS 與 DFS | 規劃中 |
| 22 | 拓樸排序、AOV 與 AOE 網路 | 規劃中 |
| 23 | 連通性：強連通元件、割點、橋與雙連通元件 | 規劃中 |
| 24 | 最小生成樹 | 規劃中 |
| 25 | 最短路徑 | 規劃中 |
| 26 | 網路流與二分匹配 | 規劃中 |
| | **第六部　其他** | |
| 27 | 字串比對 | 規劃中 |
| 28 | NP 完備 | 規劃中 |
| 29 | 近似演算法 | 規劃中 |
| | 附錄 A　數學工具 | 規劃中 |
| | 附錄 B　筆試作答寫法 | 規劃中 |

## 註解 Annotated 演算法系列

| # | 書名 | 狀態 |
|---|---|---|
| 1 | 《C++ 演算法解題 1：APCS 實作題核心》 | 草稿，[cpp-algorithms-book](https://github.com/AkizumiFox/cpp-algorithms-book) |
| 2 | 《C++ 演算法解題 2：動態規劃與圖論》 | 草稿，[cpp-algorithms-book-2](https://github.com/AkizumiFox/cpp-algorithms-book-2) |
| 3 | 《C++ 演算法解題 3：進階資料結構、數學與競賽》 | 規劃中 |
| 4 | 《資料結構與演算法：C 語言、虛擬碼與研究所考試》 | 本書，草稿（第 1 章） |

前三本用 C++17，一本接一本讀。 這一本用 C 和虛擬碼，不需要先讀前三本；書裡提到前三本時只當延伸閱讀。

## 虛擬碼的寫法

和多數演算法教科書、筆試考卷相近：陣列從 1 開始（`A[1..n]`）、指定用 `←`、比較相等用 `=`、`for i ← 2 to n`、用縮排表示區塊、程序名稱用小型大寫。 C 程式的陣列從 0 開始。 第 1 章 1.2 節有完整的對照表。

## 編譯

需要 XeLaTeX、latexmk 與 Python 的 Pygments（minted 上色用），虛擬碼用 TeX Live 的 algorithmicx（algpseudocode）。 中文字型在 macOS 上用 Songti TC／PingFang TC，找不到時改用 Noto Serif／Sans CJK TC。

```
make ch1     # 單章，輸出到 output/chapters/
make book    # 全書，輸出到 output/book.pdf
```

還沒動筆的章在 `src/book.tex` 裡是註解掉的，`Makefile` 的 `WRITTEN` 列出已經動筆的章。

## 測試書上的程式

書上每一個標題寫著 `(檔名.c)` 的範例都是完整的程式。 `make test` 會把它們從 `.tex` 抽出來（`scripts/extract_code.py`），用

```
gcc -std=c11 -O2 -Wall -Wextra -fsanitize=address,undefined
```

編譯，有任何警告就算失敗；範例後面緊接著輸入輸出範例的，再拿輸入去跑，和書上印的輸出逐字比對，執行時 stderr 有任何輸出（例如 UndefinedBehaviorSanitizer 的報告）也算失敗。 程式片段（`code` 環境）和虛擬碼（`pseudo` 環境）不抽。

測試程式在 `systemd-run --user --scope -p MemoryMax=4G` 裡執行，限制實際用到的記憶體（AddressSanitizer 會保留很大的虛擬位址空間，不能用 `ulimit -v`）。 沒有 systemd 的系統會直接執行。

## Aki-Judge 題目的引用

書中引用 Aki-Judge 的題目一律寫成 `\akiref{代號}{中文題名}`（定義在 `src/packages/sleek-aki.sty`），目前只印出「中文題名（Aki-Judge）」。

## 授權

CC BY-NC-SA 4.0。 可自由用於教學與非商業用途，改作請沿用相同授權並註明出處。
