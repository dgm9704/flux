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
- Found some version of the validation specifications from Polish Financial Supervision Authority (UKNF) site:
https://www.knf.gov.pl/knf/pl/komponenty/img/2013-ITMG-65_opis_regul_walidacyjnych_plikow_DATMAN_DATAIF_71002.xlsx
 
## My environment
- [Visual Studio Code](https://code.visualstudio.com/) on [Arch Linux](https://www.archlinux.org/) for development
- [xmllint](http://xmlsoft.org/xmllint.html) for schema validation
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for stylesheet processing

## Usage
1) Always validate your XML against the schema first.

If this gives errors, stop and correct them.
``` 
xmllint aifm.xml --schema schema/aifmd.xsd --noout
``` 
or
``` 
xmllint aif.xml --schema schema/aifmd.xsd --noout
``` 

2) Run the transformation:

``` 
xsltproc aifmd.xsl aifm.xml
``` 
or
``` 
xsltproc aifmd.xsl aif.xml
``` 

Sample output for aifmsample.xml:
(this changes as I try out different things)

"CAM-002" is ESMA error code

111111, 222222, 333333 is the AIFMNationalCode of the offending manager
```
CAM-002 111111 The reporting period start date is not allowed.

CAM-002 222222 The reporting period start date is not allowed.

CAM-002 333333 The reporting period start date is not allowed.
```

## Status
- All AIFM checks with error codes are implemented, except FIL-009 requires access to filename which isn't available for XSLT 1.0
- Because CAM-007 requires check digit calculation, which may not be possible/sane to do with XSLT 1.0, 

   I circumvent this with looking up the LEI from a list of allowed values.

- decided _for now_ to drop checks without error code
- maybe 1/3 of AIF cases are done to some degree
- output is rough and minimal
- OK to file bugs on results for implemented cases

## Next steps 
- Figure out smartest version of XSLT to use (and XPath, Xquery)
- Figure out best tool to use for XSLT
- Implement the rest of AIF cases
- Using the official error codes and messages where available
- Add manager/fund identification and other info about the error location
- Figure out the output format (CSV, XML, ?)
- Optimization if needed (it's easy to read and write when every case is explicitly "spelled out", but might perform badly)
