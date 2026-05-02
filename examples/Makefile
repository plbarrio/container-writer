DEMO = demo
POEM = poem

FILTERS       = --lua-filter=../container-writer.lua
STRIP_FILTERS = --lua-filter=../container-strip.lua --lua-filter=../container-writer.lua

OUTDIR  = output/pandoc
QOUTDIR = output/quarto

.PHONY: all review strip quarto quarto-strip \
        pdf-latex pdf-context pdf-typst html epub \
        pdf-latex-strip pdf-context-strip pdf-typst-strip html-strip epub-strip \
        pdf-latex-quarto pdf-context-quarto pdf-typst-quarto html-quarto epub-quarto \
        pdf-latex-quarto-strip pdf-context-quarto-strip pdf-typst-quarto-strip html-quarto-strip epub-quarto-strip \
        clean

all: review strip quarto quarto-strip

review: html epub
	-$(MAKE) pdf-latex
	-$(MAKE) pdf-context
	-$(MAKE) pdf-typst

strip: html-strip epub-strip
	-$(MAKE) pdf-latex-strip
	-$(MAKE) pdf-context-strip
	-$(MAKE) pdf-typst-strip

quarto: html-quarto epub-quarto
	-$(MAKE) pdf-latex-quarto
	-$(MAKE) pdf-context-quarto
	-$(MAKE) pdf-typst-quarto

quarto-strip: html-quarto-strip epub-quarto-strip
	-$(MAKE) pdf-latex-quarto-strip
	-$(MAKE) pdf-context-quarto-strip
	-$(MAKE) pdf-typst-quarto-strip

# --- phony targets ------------------------------------------

pdf-latex:   $(OUTDIR)/$(DEMO)-latex.pdf   $(OUTDIR)/$(POEM)-latex.pdf
pdf-context: $(OUTDIR)/$(DEMO)-context.pdf $(OUTDIR)/$(POEM)-context.pdf
pdf-typst:   $(OUTDIR)/$(DEMO)-typst.pdf   $(OUTDIR)/$(POEM)-typst.pdf
html:        $(OUTDIR)/$(DEMO).html        $(OUTDIR)/$(POEM).html
epub:        $(OUTDIR)/$(DEMO).epub        $(OUTDIR)/$(POEM).epub

pdf-latex-strip:   $(OUTDIR)/$(DEMO)-latex-strip.pdf
pdf-context-strip: $(OUTDIR)/$(DEMO)-context-strip.pdf
pdf-typst-strip:   $(OUTDIR)/$(DEMO)-typst-strip.pdf
html-strip:        $(OUTDIR)/$(DEMO)-strip.html
epub-strip:        $(OUTDIR)/$(DEMO)-strip.epub

pdf-latex-quarto: $(QOUTDIR)/$(DEMO)-latex.pdf $(QOUTDIR)/$(POEM)-latex.pdf
pdf-context-quarto: $(QOUTDIR)/$(DEMO)-context.pdf $(QOUTDIR)/$(POEM)-context.pdf
pdf-typst-quarto: $(QOUTDIR)/$(DEMO)-typst.pdf $(QOUTDIR)/$(POEM)-typst.pdf
html-quarto:      $(QOUTDIR)/$(DEMO).html      $(QOUTDIR)/$(POEM).html
epub-quarto:      $(QOUTDIR)/$(DEMO).epub      $(QOUTDIR)/$(POEM).epub

pdf-latex-quarto-strip: $(QOUTDIR)/$(DEMO)-latex-strip.pdf
pdf-context-quarto-strip: $(QOUTDIR)/$(DEMO)-context-strip.pdf
pdf-typst-quarto-strip: $(QOUTDIR)/$(DEMO)-typst-strip.pdf
html-quarto-strip:      $(QOUTDIR)/$(DEMO)-strip.html
epub-quarto-strip:      $(QOUTDIR)/$(DEMO)-strip.epub

$(OUTDIR) $(QOUTDIR):
	mkdir -p $@

# --- review rules (plain Pandoc) ----------------------------

$(OUTDIR)/%-latex.pdf: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=lualatex \
	  --include-in-header=styles/$*.tex \
	  -o $@ $<

$(OUTDIR)/%-context.pdf: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=context \
	  --include-in-header=styles/$*.ctx \
	  -o $@ $<

$(OUTDIR)/%-typst.pdf: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=typst \
	  --include-in-header=styles/$*.typ \
	  -o $@ $<

$(OUTDIR)/%.html: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --standalone \
	  --embed-resources \
	  --css=styles/$*.css \
	  -o $@ $<

$(OUTDIR)/%.epub: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --css=styles/$*.css \
	  -o $@ $<

# --- strip rules (plain Pandoc) -----------------------------

$(OUTDIR)/%-latex-strip.pdf: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=lualatex \
	  --include-in-header=styles/$*.tex \
	  -o $@ $<

$(OUTDIR)/%-context-strip.pdf: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=context \
	  --include-in-header=styles/$*.ctx \
	  -o $@ $<

$(OUTDIR)/%-typst-strip.pdf: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=typst \
	  --include-in-header=styles/$*.typ \
	  -o $@ $<

$(OUTDIR)/%-strip.html: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --standalone \
	  --embed-resources \
	  --css=styles/$*.css \
	  -o $@ $<

$(OUTDIR)/%-strip.epub: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --css=styles/$*.css \
	  -o $@ $<

# --- quarto rules -------------------------------------------
# Filter declared in _quarto.yml
# ConTeXt via pandoc directly (quarto render broken for context)

$(QOUTDIR)/%-latex.pdf: %.md | $(QOUTDIR)
	quarto render $< --to pdf --pdf-engine=lualatex \
	  --metadata include-in-header=styles/$*.tex \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-typst.pdf: %.md | $(QOUTDIR)
	quarto render $< --to typst \
	  --metadata include-in-header=styles/$*.typ \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-context.pdf: %.md | $(QOUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=context \
	  --include-in-header=styles/$*.ctx \
	  -o $@ $<

$(QOUTDIR)/%.html: %.md | $(QOUTDIR)
	quarto render $< --to html \
	  --metadata css=styles/$*.css \
	  --output-dir=$(QOUTDIR)

$(QOUTDIR)/%.epub: %.md | $(QOUTDIR)
	quarto render $< --to epub \
	  --metadata css=styles/$*.css \
	  --output-dir=$(QOUTDIR)

# --- quarto strip rules -------------------------------------
# Filter declared in _quarto-strip.yml

$(QOUTDIR)/%-latex-strip.pdf: %.md | $(QOUTDIR)
	quarto render $< --to pdf --pdf-engine=lualatex \
	  --metadata include-in-header=styles/$*.tex \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-typst-strip.pdf: %.md | $(QOUTDIR)
	quarto render $< --to typst \
	  --metadata include-in-header=styles/$*.typ \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-context-strip.pdf: %.md | $(QOUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=context \
	  --include-in-header=styles/$*.ctx \
	  -o $@ $<

$(QOUTDIR)/%-strip.html: %.md | $(QOUTDIR)
	quarto render $< --to html \
	  --metadata css=styles/$*.css \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR)

$(QOUTDIR)/%-strip.epub: %.md | $(QOUTDIR)
	quarto render $< --to epub \
	  --metadata css=styles/$*.css \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR)

clean:
	rm -rf output
