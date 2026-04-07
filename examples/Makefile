FILTERS       = --lua-filter=../container-writer.lua
STRIP_FILTERS = --lua-filter=../container-strip.lua --lua-filter=../container-writer.lua
INPUTS        = $(wildcard *.md)
OUTDIR        = output/pandoc
QOUTDIR       = output/quarto

PDFS_LATEX_REVIEW   = $(INPUTS:.md=-latex.pdf)
PDFS_CONTEXT_REVIEW = $(INPUTS:.md=-context.pdf)
PDFS_TYPST_REVIEW   = $(INPUTS:.md=-typst.pdf)
HTMLS_REVIEW        = $(INPUTS:.md=.html)
EPUBS_REVIEW        = $(INPUTS:.md=.epub)

PDFS_LATEX_STRIP    = $(INPUTS:.md=-latex-strip.pdf)
PDFS_CONTEXT_STRIP  = $(INPUTS:.md=-context-strip.pdf)
PDFS_TYPST_STRIP    = $(INPUTS:.md=-typst-strip.pdf)
HTMLS_STRIP         = $(INPUTS:.md=-strip.html)
EPUBS_STRIP         = $(INPUTS:.md=-strip.epub)

.PHONY: all review strip quarto quarto-strip \
        pdf-latex pdf-context pdf-typst html epub \
        pdf-latex-strip pdf-context-strip pdf-typst-strip html-strip epub-strip \
        pdf-latex-quarto pdf-typst-quarto html-quarto epub-quarto \
        pdf-latex-quarto-strip pdf-typst-quarto-strip html-quarto-strip epub-quarto-strip \
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
	-$(MAKE) pdf-typst-quarto

quarto-strip: html-quarto-strip epub-quarto-strip
	-$(MAKE) pdf-latex-quarto-strip
	-$(MAKE) pdf-typst-quarto-strip

pdf-latex:         $(addprefix $(OUTDIR)/,$(PDFS_LATEX_REVIEW))
pdf-context:       $(addprefix $(OUTDIR)/,$(PDFS_CONTEXT_REVIEW))
pdf-typst:         $(addprefix $(OUTDIR)/,$(PDFS_TYPST_REVIEW))
html:              $(addprefix $(OUTDIR)/,$(HTMLS_REVIEW))
epub:              $(addprefix $(OUTDIR)/,$(EPUBS_REVIEW))

pdf-latex-strip:   $(addprefix $(OUTDIR)/,$(PDFS_LATEX_STRIP))
pdf-context-strip: $(addprefix $(OUTDIR)/,$(PDFS_CONTEXT_STRIP))
pdf-typst-strip:   $(addprefix $(OUTDIR)/,$(PDFS_TYPST_STRIP))
html-strip:        $(addprefix $(OUTDIR)/,$(HTMLS_STRIP))
epub-strip:        $(addprefix $(OUTDIR)/,$(EPUBS_STRIP))

pdf-latex-quarto:       $(addprefix $(QOUTDIR)/,$(PDFS_LATEX_REVIEW))
pdf-typst-quarto:       $(addprefix $(QOUTDIR)/,$(PDFS_TYPST_REVIEW))
html-quarto:            $(addprefix $(QOUTDIR)/,$(HTMLS_REVIEW))
epub-quarto:            $(addprefix $(QOUTDIR)/,$(EPUBS_REVIEW))

pdf-latex-quarto-strip: $(addprefix $(QOUTDIR)/,$(PDFS_LATEX_STRIP))
pdf-typst-quarto-strip: $(addprefix $(QOUTDIR)/,$(PDFS_TYPST_STRIP))
html-quarto-strip:      $(addprefix $(QOUTDIR)/,$(HTMLS_STRIP))
epub-quarto-strip:      $(addprefix $(QOUTDIR)/,$(EPUBS_STRIP))

$(OUTDIR) $(QOUTDIR):
	mkdir -p $@

# --- review rules (plain Pandoc) ----------------------------

$(OUTDIR)/%-latex.pdf: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=lualatex \
	  --include-in-header=styles/demo-preamble.tex \
	  -o $@ $<

$(OUTDIR)/%-context.pdf: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=context \
	  --include-in-header=styles/demo.ctx \
	  -o $@ $<

$(OUTDIR)/%-typst.pdf: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --pdf-engine=typst \
	  --include-in-header=styles/demo.typ \
	  -o $@ $<

$(OUTDIR)/%.html: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --standalone \
	  --embed-resources \
	  --css=styles/demo.css \
	  -o $@ $<

$(OUTDIR)/%.epub: %.md | $(OUTDIR)
	pandoc $(FILTERS) \
	  --css=styles/demo.css \
	  -o $@ $<

# --- strip rules (plain Pandoc) -----------------------------

$(OUTDIR)/%-latex-strip.pdf: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=lualatex \
	  --include-in-header=styles/demo-preamble.tex \
	  -o $@ $<

$(OUTDIR)/%-context-strip.pdf: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=context \
	  --include-in-header=styles/demo.ctx \
	  -o $@ $<

$(OUTDIR)/%-typst-strip.pdf: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --pdf-engine=typst \
	  --include-in-header=styles/demo.typ \
	  -o $@ $<

$(OUTDIR)/%-strip.html: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --standalone \
	  --embed-resources \
	  --css=styles/demo.css \
	  -o $@ $<

$(OUTDIR)/%-strip.epub: %.md | $(OUTDIR)
	pandoc $(STRIP_FILTERS) \
	  --css=styles/demo.css \
	  -o $@ $<

# --- quarto rules -------------------------------------------
# Filter declared in _quarto.yml

$(QOUTDIR)/%-latex.pdf: %.md | $(QOUTDIR)
	quarto render $< --to pdf --pdf-engine=lualatex \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-typst.pdf: %.md | $(QOUTDIR)
	quarto render $< --to typst \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%.html: %.md | $(QOUTDIR)
	quarto render $< --to html --output-dir=$(QOUTDIR)

$(QOUTDIR)/%.epub: %.md | $(QOUTDIR)
	quarto render $< --to epub --output-dir=$(QOUTDIR)

# --- quarto strip rules -------------------------------------
# Filter declared in _quarto-strip.yml

$(QOUTDIR)/%-latex-strip.pdf: %.md | $(QOUTDIR)
	quarto render $< --to pdf --pdf-engine=lualatex \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-typst-strip.pdf: %.md | $(QOUTDIR)
	quarto render $< --to typst \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR) --output $(notdir $@)

$(QOUTDIR)/%-strip.html: %.md | $(QOUTDIR)
	quarto render $< --to html \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR)

$(QOUTDIR)/%-strip.epub: %.md | $(QOUTDIR)
	quarto render $< --to epub \
	  --metadata-file=_quarto-strip.yml \
	  --output-dir=$(QOUTDIR)

clean:
	rm -rf output
