# flux

## AIFMD report validation using XSLT

- Main focus are ESMA AIFMD XML reports, but the same structure should be viable for other formats in the future also (CSDR, MMF etc)
- The goal is to implement all ESMA CAM/CAF validation rules.
- These are mostly conditional existence checks based on the existence or value of another element.
- The actual "product" is the *.xsl files, anything else is just for testing or documentation
- Validations should be trivial to run with any XSLT processor
- The output is very rudimentary for now. After all the rules are implemented, the output can be polished.
- XSLT (and XPATH, XQUERY) version used is 1.0, as this provides best tooling support. Some functionality will be missing because of this.
- Check digit calculations are not implemented, but have been replaced with lookups instead.

## Specifications
- For some reason ESMA does not provide the specifications for the validations publicly, and neither does FIN-FSA.
- I found some version of the validation specifications from Polish Financial Supervision Authority (UKNF) site:
https://www.knf.gov.pl/knf/pl/komponenty/img/2013-ITMG-65_opis_regul_walidacyjnych_plikow_DATMAN_DATAIF_71002.xlsx
- ESMA provides [technical rules for the fields](https://www.esma.europa.eu/document/aifmd-reporting-it-technical-guidance-rev-4-updated)
 
## My environment
- [Visual Studio Code](https://code.visualstudio.com/) on [Arch Linux](https://www.archlinux.org/) for development
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for stylesheet processing
- [xmllint](http://xmlsoft.org/xmllint.html) for schema validation

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

"CAM-002" is ESMA error code

111111 AIFMNationalCode of the offending manager
```
<error><record>111111</record><code>CAM-002</code><message>The reporting period start date is not allowed.</message><field>ReportingPeriodStartDate</field><value>2014-09-01</value></error>

```

## Status
- All validations (CAM/CAF/FIL/WAF) have been implemented in some way, except:
    - FIL-009 requires access to filename which isn't available for XSLT 1.0
    - CAM-001, CAF-001, CAF-005 only make sense when done by ESMA
    - Checkdigit calculations are implemented with ESXLT extensions available with xsltproc
- output is rough and minimal
- OK to file bugs on results for implemented cases

## Next steps 
- Add richer info about the error location and related values.
- If possible, find out the output format that ESMA uses!
- There are some warnings also (WAF-*) - do they go into a "warning" element, or should there be a severity value?

## How you can help
- testing and filing issues against specific validations
- providing up-to-date specifications
- providing test reports 
- **Do not send me anything that is confidential or that can't be shared publicly**

