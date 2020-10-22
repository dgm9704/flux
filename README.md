# flux

## XML document validation using XSLT

- Main focus are ESMA XML reports (AIMFD, CSDR, MMF etc)
- The purpose is to implement validation of rules that are not covered by an XSD schema.
- These are mostly conditional existence checks based on the existence or value of another element.
- The actual "product" is the *.xsl files, anything else is just for testing or documentation
- Validations should be trivial to run with any XSLT processor
- The output is very rudimentary for now, the actual format and contents will be decided later

## Specifications
- ESMA provides [technical rules for the fields](https://www.esma.europa.eu/document/aifmd-reporting-it-technical-guidance-rev-4-updated)
- ESMA also has validation codes and error messages for these rules, but for some reason they are not available on their website. 
 When I asked about this, I was told to contact the relevant National Compentent Authority.
 I sent a question to FIN-FSA, the Finnish Financial Supervisory Authority, and I am waiting for an answer from them.
### UPDATE 
Found some version of the validation specifications from Polish Financial Supervision Authority (UKNF) site:
https://www.knf.gov.pl/knf/pl/komponenty/img/2013-ITMG-65_opis_regul_walidacyjnych_plikow_DATMAN_DATAIF_71002.xlsx
 
## Environment
- [Visual Studio Code](https://code.visualstudio.com/) on [Arch Linux](https://www.archlinux.org/) for development
- [xmllint](http://xmlsoft.org/xmllint.html) for schema validation
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for stylesheet processing

## Usage
1) Always validate your XML against the schema first.

If this gives errors, stop and correct them.
(The wrapper is just to help with loading multiple schemafiles)
``` 
xmllint aifsample.xml --schema schema/wrapper_aifmd.xsd --noout
``` 
OR
``` 
xmllint aifmsample.xml --schema schema/wrapper_aifmd.xsd --noout
``` 

2) Run the transformation:

(Separate stylesheets for now until all cases are covered)
``` 
xsltproc aifm.xsl aifmsample.xml
``` 
OR
``` 
xsltproc aif.xsl aifsample.xml
``` 

Sample output for aifmsample.xml:

"CAM-004" is ESMA error code
"ERROR 21.a" means error for Id 12 in the ESMA document, and first part of multipart check, where the implemented check doesn't match ESMA specificatin for some reason. 
```
CAM-004

CAM-004

CAM-004

            ERROR 21.a

            ERROR 21.b

            ERROR 28.b

            ERROR 28.a

CAM-011

CAM-013

            ERROR 36.a

            ERROR 36.b

            ERROR 37.a

            ERROR 37.b

CAM-020

CAM-020
```

## Status
- All AIFM cases have been implemented
- roughly 1/2 of AIF cases are implemented
- output is rough and minimal
- OK to file bugs on results for implemented cases

## Next steps 
- Implement the rest of AIF cases
- Using the official error codes and messages where available
- Figure out the best way of combining or separating stuff into files
  
  (Most likely everything in one file)
- Add manager/fund identification and other info about the error location
- Figure out the output format (CSV, XML, ?)
- Optimization if needed (it's easy to read and write when every case is explicitly "spelled out", but might perform badly)
