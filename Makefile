# Makefile for LaTeX files

# Original Makefile from http://www.math.psu.edu/elkin/math/497a/Makefile

# Copyright (c) 2005 Matti Airas <Matti.Airas@hut.fi>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions: 

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

# $Id: Makefile,v 1.13 2005/02/03 12:32:14 mairas Exp $

LATEX	= latex
BIBTEX	= bibtex
MAKEINDEX = makeindex
XDVI	= xdvi -gamma 4
XDVIPROC= xdvi-xaw
DVIPS	= dvips
DVIPDF  = dvipdf
PS2PDF = ps2pdf
L2H	= latex2html
GH	= gv

RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)|Citation.*undefined"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"
MAKEIDX = "^[^%]*\\makeindex"
MPRINT = "^[^%]*print"
USETHUMBS = "^[^%]*thumbpdf"

SRC	:= $(shell egrep -l '^[^%]*\\begin\{document\}' *.tex)
# Here is BWP hack: add /home/bwp/r/bibs/ to bibfile.  Need a 'which'-type cmd.
BIBFILE := $(shell perl -ne '($$_)=/^[^%]*\\bibliography\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bib"}' $(SRC))

EPSPICS := $(shell perl -ne '@foo=/^[^%]*\\(includegraphics|psfig)(\[.*?\])?\{(.*?)\}/g;if (defined($$foo[2])) { if ($$foo[2] =~ /.eps$$/) { print "$$foo[2] "; } else { print "$$foo[2].eps "; }}' *.tex)
DEP	= *.tex

TRG	= $(SRC:%.tex=%.dvi)
PSF	= $(SRC:%.tex=%.ps)
PDF	= $(SRC:%.tex=%.pdf)

COPY = if test -r $(<:%.tex=%.toc); then cp $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); fi 
RM = rm -f
OUTDATED = echo "EPS-file is out-of-date!" && false


all 	: $(TRG)
	$(refreshxdvi)

define run-latex
	$(COPY)
	$(LATEX) $<
	egrep -q $(MAKEIDX) $< && ($(MAKEINDEX) $(<:%.tex=%);$(COPY);$(LATEX) $<) ; true
	egrep -c $(RERUNBIB) $(<:%.tex=%.log) && ($(BIBTEX) $(<:%.tex=%);$(COPY);$(LATEX) $<) ; true
	egrep -q $(RERUN) $(<:%.tex=%.log) && ($(COPY);$(LATEX) $<) ; true
	egrep -q $(RERUN) $(<:%.tex=%.log) && ($(COPY);$(LATEX) $<) ; true
	if cmp -s $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); then true ;else $(LATEX) $< ; fi
	$(RM) $(<:%.tex=%.toc.bak)
	# Display relevant warnings
	egrep -i "(Reference|Citation).*undefined" $(<:%.tex=%.log) ; true
endef

define refreshxdvi
	-@killall -USR1 $(XDVIPROC)
endef

$(TRG)	: %.dvi : %.tex $(DEP) $(EPSPICS) $(BIBFILE)
	  @$(run-latex)

$(PSF)	: %.ps : %.dvi
	  @$(DVIPS) $< -o $@

$(PDF)  : %.pdf : %.dvi
	# tmp-file scheme so that Apple Preview doesn't give up on the temporarily-invalid new file
	@$(DVIPDF)  $< tmp.pdf
	mv tmp.pdf $@

#$(PDF)  : %.pdf : %.ps
#	  @$(PS2PDF) -p letter $<

show	: $(TRG)
	  @for i in $(TRG) ; do $(XDVI) $$i & ; done

showps	: $(PSF)
	  @for i in $(PSF) ; do $(GH) $$i & ; done

ps	: $(PSF) 

pdf	: clean $(PDF) 

# TODO: This probably needs fixing
#html	: @$(DEP) $(EPSPICS)
#	  @$(L2H) $(SRC)

clean	:
	  -rm -f $(TRG) $(PSF) $(PDF) $(TRG:%.dvi=%.aux) $(TRG:%.dvi=%.bbl) $(TRG:%.dvi=%.blg) $(TRG:%.dvi=%.log) $(TRG:%.dvi=%.toc) $(TRG:%.dvi=%.out) *~

.PHONY	: all show clean ps pdf showps


######################################################################
# Define rules for EPS source files.
%.eps: %.sxd
	$(OUTDATED)
%.eps: %.sda
	$(OUTDATED)
%.eps: %.png
	$(OUTDATED)
%.eps: %.sxc
	$(OUTDATED)
%.eps: %.xcf
	$(OUTDATED)
%.eps: %.zargo
	$(OUTDATED)
%.eps: %.m
	@egrep -q $(MPRINT) $< && ($(OUTDATED))
