.PHONY: help book chapters test clean cleanall all FORCE

SHELL := /bin/bash
SRCDIR := src
BUILDDIR := build
OUTDIR := output
CHAPTERS_OUTDIR := $(OUTDIR)/chapters

# 已經動筆的章（目錄名稱）。新的一章開始寫時加進來，book.tex 也要取消註解。
WRITTEN := 01_Analysis 02_Recurrences 03_Amortized 04_ArraysMatrices 05_LinkedLists 06_StacksQueues 07_Trees 08_Heaps 09_BST 10_BalancedTrees 11_MultiwayTrees 12_Hashing 13_DisjointSets 14_Sorting 15_LinearExternalSort 16_Selection 17_DivideConquer 18_DynamicProgramming 19_Greedy 20_Backtracking 21_GraphTraversal 22_TopologicalSort 23_Connectivity 24_MST 25_ShortestPaths 26_NetworkFlow 27_StringMatching 28_NPCompleteness 29_Approximation

# Compile from BUILDDIR so aux/log/minted/pdf intermediates never land in src/.
# Trailing colon on TEXINPUTS keeps TeX Live's default search path.
BUILD_TEXINPUTS := ../$(SRCDIR):../$(SRCDIR)/packages:
LATEXMK := latexmk -xelatex -cd- -output-directory=. -aux-directory=. -latexoption="-file-line-error -halt-on-error" -shell-escape -silent -interaction=nonstopmode

# 所有章的目錄，例如 07_Greedy；chN 依編號找到對應的目錄。
CHAPTER_DIRS := $(notdir $(wildcard $(SRCDIR)/chapters/[0-9][0-9]_*))
chapter_dir = $(filter $(shell printf '%02d' $(1))_%,$(CHAPTER_DIRS))

help:
	@echo "Book build system"
	@echo ""
	@echo "Targets:"
	@echo "  make book         - Build full book PDF (output/book.pdf)"
	@echo "  make ch1          - Build one chapter (output/chapters/)"
	@echo "  make chapters     - Build every written chapter"
	@echo "  make test         - Extract C examples from .tex, compile (C11 + ASan/UBSan) and check iosample"
	@echo "  make clean        - Delete build artifacts"
	@echo "  make cleanall     - Delete all PDFs + artifacts"

all: book chapters

book: $(OUTDIR)/book.pdf
	@:

chapters: $(foreach d,$(WRITTEN),$(CHAPTERS_OUTDIR)/$(d).pdf)
	@echo "✓ All written chapters compiled to $(CHAPTERS_OUTDIR)/"

# make ch1、make ch12 …
ch%:
	@d="$(call chapter_dir,$*)"; \
	if [ -z "$$d" ]; then echo "No chapter $*"; exit 1; fi; \
	$(MAKE) --no-print-directory $(CHAPTERS_OUTDIR)/$$d.pdf

# Full book: copy the driver into BUILDDIR (do not compile ../src/book.tex in
# place — latexmk/xelatex would write aux/log/minted next to the source).
$(OUTDIR)/book.pdf: FORCE
	@mkdir -p $(BUILDDIR) $(OUTDIR)
	@echo "Building: Full book..."
	@cp $(SRCDIR)/book.tex $(BUILDDIR)/book.tex
	@TEXINPUTS="$(BUILD_TEXINPUTS)" scripts/build_tex.sh $(BUILDDIR) book.tex $(LATEXMK)
	@cp $(BUILDDIR)/book.pdf $(OUTDIR)/book.pdf
	@echo "✓ $(OUTDIR)/book.pdf"

# 單章：把 book.tex 的導言區複製一份，只放這一章。
$(CHAPTERS_OUTDIR)/%.pdf: FORCE
	@mkdir -p $(BUILDDIR) $(CHAPTERS_OUTDIR)
	@echo "Building chapter: $*..."
	@wrapper="$(BUILDDIR)/chapter-$*.tex" && \
	chap_num=$$(echo "$*" | grep -o '^[0-9]\+') && \
	sed -e '/\\include{chapters/d' -e '/\\input{chapters/d' -e '/\\setcounter{chapter}/d' \
	    -e '/\\end{document}/d' -e '/\\maketitle/d' -e '/\\romantableofcontents/d' \
	    -e '/\\tableofcontents/d' $(SRCDIR)/book.tex > "$$wrapper" && \
	echo "\\setcounter{chapter}{$$(( 10#$$chap_num - 1 ))}" >> "$$wrapper" && \
	echo "\\input{../$(SRCDIR)/chapters/$*/chapter}" >> "$$wrapper" && \
	echo "\\end{document}" >> "$$wrapper" && \
	TEXINPUTS="$(BUILD_TEXINPUTS)" scripts/build_tex.sh $(BUILDDIR) chapter-$*.tex $(LATEXMK) && \
	cp $(BUILDDIR)/chapter-$*.pdf $(CHAPTERS_OUTDIR)/$*.pdf && echo "✓ $(CHAPTERS_OUTDIR)/$*.pdf"

# 從 .tex 抽出範例程式，用 gcc -std=c11 -O2 -Wall -Wextra -fsanitize=address,undefined
# 編譯，再拿 iosample 的輸入跑，和預期輸出比對。
# 測試程式放在 systemd 的 scope 裡跑，實際記憶體用量上限 4G（ASan 不能用 ulimit -v）。
# 沒有 systemd 的機器上直接跑，自己先下 ulimit。
test:
	@rm -rf $(BUILDDIR)/code
	@python3 scripts/extract_code.py --out $(BUILDDIR)/code $(foreach d,$(WRITTEN),$(SRCDIR)/chapters/$(d)/chapter.tex)
	@if [ -z "$$DSA_MEMCAP" ] && command -v systemd-run > /dev/null 2>&1; then \
	    systemd-run --user --scope --quiet -p MemoryMax=4G \
	        env DSA_MEMCAP=1 UBSAN_OPTIONS=print_stacktrace=1 scripts/run_tests.sh $(BUILDDIR)/code; \
	else \
	    UBSAN_OPTIONS=print_stacktrace=1 scripts/run_tests.sh $(BUILDDIR)/code; \
	fi

FORCE:

clean:
	@rm -rf ./$(BUILDDIR)
	@echo "✓ Build artifacts cleaned"

cleanall: clean
	@rm -rf ./$(OUTDIR)
	@echo "✓ All outputs cleaned"
