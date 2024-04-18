# flux

## ESMA XML report validation using XSLT

- Main focus are ESMA AIFMD XML reports, but the same structure should be viable for other formats in the future also (CSDR, MMF etc)
- The goal is to implement all ESMA CAM/CAF validation rules.
- These are mostly conditional existence checks based on the existence or value of another element.
- The actual "product" is the *.xslt files, anything else is just for testing or documentation
- Validations should be trivial to run with any XSLT processor
- The output is very rudimentary for now. After all the rules are implemented, the output can be polished.
- XSLT (and XPATH, XQUERY) version used is 1.0, as this provides best tooling support. Some functionality will be missing because of this.

## Specifications

### AIFMD
   For some reason ESMA does not provide the specifications for AIFMD validations publicly, and neither does FIN-FSA.
   ESMA provides [technical rules for the fields](https://www.esma.europa.eu/document/aifmd-reporting-it-technical-guidance-rev-4-updated)
   I have found some versions of the AIFMD validation specifications from other sources:
   
   - Polish Financial Supervision Authority (UKNF)

https://www.knf.gov.pl/knf/pl/komponenty/img/2013-ITMG-65_opis_regul_walidacyjnych_plikow_DATMAN_DATAIF_71002.xlsx

   - Finanzmarktaufsicht Liechtenstein (FMA)

https://www.fma-li.li/files/list/fma-wegleitung-2020-8-aifmd-reporting-fehlermeldungen.pdf

   - Luxemburg Commission de Surveillance du Secteur Financier (CSSF) 

   https://www.cssf.lu/wp-content/uploads/CSSF_ERROR_CODES_FEEDBACK_FILES.pdf
   
   - Bundesanstalt für Finanzdienstleistungsaufsicht (BaFin)
   
   https://www.bafin.de/SharedDocs/Downloads/DE/Merkblatt/WA/dl_150305_merkbl_35KAGB_Anlage2_AIFM_wa.pdf?__blob=publicationFile&v=3
   
   https://www.bafin.de/SharedDocs/Downloads/DE/Merkblatt/WA/dl_150305_merkbl_35KAGB_Anlage1_AIF_wa.pdf?__blob=publicationFile&v=1
   
### CSDR9

- Technical Guidance for Settlement Internalisers – Report Validation Rules (CSDR Article 9) 

https://www.esma.europa.eu/sites/default/files/library/esma65-8-6561_csdr-technical_guidance_for_settlement_internalisers_report_validation_rules.pdf

## My environment
   - [Visual Studio Code](https://code.visualstudio.com/) on [Arch Linux](https://www.archlinux.org/) for development
   - [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for stylesheet processing
   - [xmllint](http://xmlsoft.org/xmllint.html) for schema validation

## Usage
1) Always validate your XML against the schema first.

If this gives errors, stop and correct them.
``` 
xmllint report/aifm.xml --schema schema/aifmd.xsd --noout
``` 
or
``` 
xmllint report/aif.xml --schema schema/aifmd.xsd --noout
``` 

2) Run the transformation:

``` 
xsltproc aifmd.xslt report/aifm.xml
``` 
or
``` 
xsltproc aifmd.xslt report/aif.xml
``` 

Sample output for aif validation errors:

111111#001 AIFNationalCode of the offending fund
```
  <error>
    <record>111111#001</record>
    <code>CAF-146</code>
    <control>The ranks that are assigned to the reported values should be consistent in relation to each other. First rank values are above or equal to the second rank values and so on.</control>
    <message>The reported value is not consistent with the rank.</message>
    <context>
      <field>
        <name>AIFReportingInfo/AIFRecordInfo/AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4/BorrowingSource/Ranking/</name>
        <value>1</value>
      </field>
      <field>
        <name>AIFReportingInfo/AIFRecordInfo/AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4/BorrowingSource/LeverageAmount/</name>
        <value>111111</value>
      </field>
    </context>
  </error>

```

## Status

### Started implementing ESEF validations 

### CSDR9 validations have been implemented!

### AIFMD validations have been implemented!

	Exceptions: 
    - FIL-009 is a filename check
    - CAM-001, CAF-001, CAF-005 only make sense when done by ESMA


- Checkdigit calculations are implemented with ESXLT extensions available with xsltproc

- Output now includes all values relevant to the validation that are available at execution time

- OK to file bugs!


## Next steps 
- Think about packaging, instructions etc.
- Add richer info about the error location and related values from specifications
- Add more info about the validation to the error (perhaps controllable via argument)
- If possible, find out the output format that ESMA uses!
- There are some warnings also (WAF-*) - do they go into a "warning" element, or should there be a severity value?
- Implement CSDR7 validations?
- Implement MMF validations?
- Implement ESEF validations?


## How you can help
- testing and filing issues against specific validations
- providing up-to-date specifications
- providing test reports 
- **Do not send me anything that is confidential or that can't be shared publicly**

