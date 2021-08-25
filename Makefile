PY=python
PANDOC=pandoc

# BASEDIR ends with "/"
BASEDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
INPUTDIR=${BASEDIR}source
OUTPUTDIR=${BASEDIR}output
TEMPLATEDIR=${INPUTDIR}/templates
STYLEDIR=${BASEDIR}style

BIBFILE=${INPUTDIR}/references.bib

DOCNAME=thesis
NOW=$(shell date +%Y-%m-%d+%H%M%S)

help:
	@echo ' 																	  '
	@echo 'Makefile for the Markdown thesis                                       '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        generate a web version             '
	@echo '   make pdf                         generate a PDF file  			  '
	@echo '   make docx	                       generate a Docx file 			  '
	@echo '   make tex	                       generate a Latex file 			  '
	@echo '                                                                       '
	@echo ' 																	  '
	@echo ' 																	  '
	@echo 'get local templates with: pandoc -D latex/html/etc	  				  '
	@echo 'or generic ones from: https://github.com/jgm/pandoc-templates		  '


# convert dia files to png automatically
# use the filename with the extension .png in your markdown text/code
dia:
	cd ${INPUTDIR}/figures/dia/ && dia -t png *.dia


convert: dia


# for other csl styles look at https://github.com/citation-style-language/styles
pdf: convert
	pandoc ${INPUTDIR}/*.md \
	-o ${OUTPUTDIR}/${DOCNAME}.pdf \
	-H ${STYLEDIR}/preamble.tex \
	--filter pandoc-crossref \
	--template=${STYLEDIR}/template.tex \
	--bibliography=${BIBFILE} \
	--csl=${STYLEDIR}/ref_format.csl \
	--highlight-style pygments \
	--citeproc \
	-V fontsize=12pt \
	-V papersize=a4paper \
	-V documentclass=report \
	-V lang:german \
	-V mainlang:german \
	-N \
	--pdf-engine=xelatex \
	--verbose


tex: convert
	pandoc "${INPUTDIR}"/*.md \
	-o "${OUTPUTDIR}/${DOCNAME}.tex" \
	-H "${STYLEDIR}/preamble.tex" \
	--filter pandoc-crossref \
	--bibliography="${BIBFILE}" \
	-V fontsize=12pt \
	-V papersize=a4paper \
	-V documentclass=report \
	-V lang:german \
	-V mainlang:german \
	-N \
	--csl="${STYLEDIR}/ref_format.csl" \
	--latex-engine=xelatex


docx: convert
	pandoc "${INPUTDIR}"/*.md \
	-o "${OUTPUTDIR}/${DOCNAME}.docx" \
	--filter pandoc-crossref \
	--bibliography="${BIBFILE}" \
	--csl="${STYLEDIR}/ref_format.csl" \
	--toc


html: convert
	pandoc "${INPUTDIR}"/*.md \
	-o "${OUTPUTDIR}/${DOCNAME}.html" \
	--filter pandoc-crossref \
	--standalone \
	--template="${STYLEDIR}/template.html" \
	--bibliography="${BIBFILE}" \
	--csl="${STYLEDIR}/ref_format.csl" \
	--include-in-header="${STYLEDIR}/style.css" \
	--toc \
	--number-sections
	rm -rf "${OUTPUTDIR}/source"
	mkdir "${OUTPUTDIR}/source"
	cp -r "${INPUTDIR}/figures" "${OUTPUTDIR}/source/figures"


epub: convert
	pandoc "${INPUTDIR}"/*.md \
	-o "${OUTPUTDIR}/${DOCNAME}.epub" \
	--filter pandoc-crossref \
	--standalone \
	--template="${STYLEDIR}/template-default.epub3" \
	--css "${STYLEDIR}/epub-mobileread.css" \
	--bibliography="${BIBFILE}" \
	--csl="${STYLEDIR}/ref_format.csl" \
	--epub-cover-image="${STYLEDIR}/cover.png" \
	--toc \
	--number-sections
	rm -rf "${OUTPUTDIR}/source"
	mkdir "${OUTPUTDIR}/source"
	cp -r "${INPUTDIR}/figures" "${OUTPUTDIR}/source/figures"


# copies the current version of your thesis in different file formats
# to your server (e.g. www.uberspace.de)
# * pdf
# * epub
# * html including figures using rsync
upload: pdf epub html
	scp "${OUTPUTDIR}/${DOCNAME}.pdf" "username@server.de:/thesis/${NOW}_${DOCNAME}.pdf"
	scp "${OUTPUTDIR}/${DOCNAME}.epub" "username@server.de:/thesis/${NOW}_${DOCNAME}.epub"
	scp "${OUTPUTDIR}/${DOCNAME}.html" "username@server.de:/thesis/${NOW}_${DOCNAME}.html"
	rsync -rtvhze ssh output/source username@server.de:/thesis/

.PHONY: help pdf docx html tex epub upload
