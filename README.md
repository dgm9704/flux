# flux
XML document validation using XSLT

- Main focus are ESMA XML reports (AIMFD, CSDR, MMF etc)
- The purpose is to implement validation of rules that are not covered by an XSD schema.
- These are mostly conditional existence checks based on the existence or value of another element.
- Validations should be trivial to run with any XSLT processor
- The output is very rudimentary for now, the actual format and contents will be decided later

Specifications
- ESMA provides [technical rules for the fields](https://www.esma.europa.eu/document/aifmd-reporting-it-technical-guidance-rev-4-updated)
- ESMA also has validation codes and error messages for these rules, but for some reason they are not available on their website. 
 When I asked about this, I was told to contact the relevant National Compentent Authority.
 I sent a question to FIN-FSA, the Finnish Financial Supervisory Authority, and I am waiting for an answer from them.
 
I use 
- [Visual Studio Code](https://code.visualstudio.com/) on [Arch Linux](https://www.archlinux.org/) for development
- [xmllint](http://xmlsoft.org/xmllint.html) for schema validation
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for stylesheet processing
