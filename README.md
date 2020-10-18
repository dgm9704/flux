# flux
XML document validation using XSLT

- Main focus are ESMA XML reports (AIMFD, CSDR, MMF etc)
- The purpose is to implement validation of rules that are not covered by an XSD schema.
- These are mostly conditional existence checks based on the existence or value of another element.
- Validations should be trivial to run with any XSLT processor
- The output is very rudimentary for now, the actual format and contents will be decided later

I use 
- [Visual Studio Code](https://code.visualstudio.com/) on [Arch Linux](https://www.archlinux.org/) for development
- [xmllint](http://xmlsoft.org/xmllint.html) for schema validation
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for stylesheet processing
