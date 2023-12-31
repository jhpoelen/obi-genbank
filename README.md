---
title: Extending OBI Herbarium Records to include associated NCBI GenBank sequences 
subtitle: hash://md5/40b93e072ceb31bb9e78078b929f19d8 hash://sha256/be5605e58d2644baedcb160604080d9f02ce528064b7fbb13a5b556dd55cfeb6 
author: 
  - Jorrit Poelen
  - Katelin Pearson
  - Jenn Yost
date: 2023-07-19
abstract: |
  Specimen from Natural History Collections are physical repositories of genetic information. Genetic sequences extracted from
  specimen are stored in genetic sequence databases like the openly accessible GenBank at NCBI, DNA DataBank of Japan, or the European Nucleotide Archive (ENA). 
  While researchers and collection managers make efforts to associate
  (or link) Natural History Collection records with their derived genetic accession records, extra work is need to make these associations explicit. We describe how a collaboration between a biodiversity informatics expert and collection managers of the Hoover/OBI Herbarium at CalPoly, San Luis Obispo, CA was forged with the aim to extend OBI specimen records to include their associated GenBank records. In addition, we quantify the costs of creating these specimen extensions, and discuss the socio-economic capacity needed to repeat this digital specimen extension process for the hundreds of millions of specimen records available globally today.  
bibliography: biblio.bib
reference-section-title: References
header-includes:
 - \usepackage{fvextra}
 - \DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,breakanywhere,commandchars=\\\{\}}
---


https://linker.bio/hash://sha256/be5605e58d2644baedcb160604080d9f02ce528064b7fbb13a5b556dd55cfeb6

[![SWH](https://archive.softwareheritage.org/badge/swh:1:dir:2b8a4eb0f0a03739a39927066de5540b1ab88e5d/)](https://archive.softwareheritage.org/swh:1:dir:2b8a4eb0f0a03739a39927066de5540b1ab88e5d;origin=https://github.com/jhpoelen/obi-genbank;visit=swh:1:snp:69fccddef82dd6bfa4248e1519dfe4c041f425b0;anchor=swh:1:rev:988e0fd1e19d9eaefb8fde35882e6d53ee8f482a)

## Introduction

Billions of biodiversity data records are made openly available by hundreds of Natural History Collections all over the world. Also, since 1982, National Institutes of Health have published versions nucleotide sequences through GenBank. Many specimen described in Natural History Collections have associated GenBank sequence accessions available in GenBank. 

During the 2023 Annual Conference of Digital Data in Biodiversity Research hosted by Arizona State University, Jenn Yost expressed a desire to make it easier to link GenBank accession records to the specimen records the helps curate at the The Hoover Herbarium (```{ "http://rs.tdwg.org/dwc/terms/institutionCode": "OBI"}```), Cal Poly State University, San Luis Obispo, CA [@Yost_2023].

![Jenn Yost expressing her desire to better link GenBank records to their associated specimen records [@Yost_2023].](yost.svg)

This repository is the outcome at a first prototype to help outline a process to discover OBI specimen record references in GenBank. With this, Jenn Yost and collaborators like Kate Pearson can link specimen records to the GenBank accession they are associated with. 

![Hoover Herbarium (OBI) at Cal Poly State University, San Luis Obispo, CA keeps herbarium specimen. Some of these specimen have associated record in GenBank. These GenBank records extend the OBI specimen additional information such as genetic sequences.](./challenge.svg)

### Example

The Hoover Herbarium hosts a preserved specimen of type _Angelica hendersonii_ Coult. & Rose that was collected in 1966-07-05 by Tracey & Viola Call at the north end of Tomales Bay and 2 mi south of Tomales in Marin County, California with catalog number: OBI09031, collector number: 2490, occurrence id: 256368e3-f8d7-4028-8010-1a4ff3eb8111, and web reference [https://cch2.org/portal/collections/individual/index.php?occid=166203](https://cch2.org/portal/collections/individual/index.php?occid=166203).

![Webpage associated with OBI09031 as seen via [https://cch2.org/portal/collections/individual/index.php?occid=166203](https://cch2.org/portal/collections/individual/index.php?occid=166203) on 2023-09-11.](./OBI09031.png)


GenBank hosts a accession record [https://www.ncbi.nlm.nih.gov/nuccore/MT735455](https://www.ncbi.nlm.nih.gov/nuccore/MT735455) with locus Angelica hendersonii voucher Tracey & V. Call 2490 (OBI09031) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. 

![Webpage associated with GenBank accession MT735455 as seen via [https://www.ncbi.nlm.nih.gov/nuccore/MT735455](https://www.ncbi.nlm.    nih.gov/nuccore/MT735455) on 2023-09-11.](./MT735455.png)

Our desire is to develop a method to facilitate the discovery of this preserved specimen and their associated GenBank accession records. The annotated web page screenshots below gives some hints to what information elements may be used to help associated related records.

![At first glance, the highlighted parts of the html pages appear to suggest evidence of association between specimen record OBI09031 and accession record MT735455. These associations include OBI (the institution code), _Angelica hendersonii_ (taxonomic identification), 1966 (collection year), 2490 (collector number), 9031 (secondary catalog), and Tracy Call and Viola Call (collectors).
](./visual.svg)

## Methods

Instead of relying on visual inspection of individual html pages for herbarium specimen and GenBank accession records, an data-driven workflow was designed to first acquire and version GenBank and OBI records. Then, using these versioned archives, the records are analyzed and associated record candidates are proposed. 

![Version, Filter and Merge Workflow](./process.svg)

### Phase 1. Acquire and Version

#### Acquire and Version GenBank Accession Records

GenBank publishes their sequence accession records in flat file archives online via https://ftp.ncbi.nlm.nih.gov/genbank/ . Their publications are published grouped by divisions. One of these divisions, the so-called PLN division, covers sequences of plants, fungi and algae. 

We used Preston, a biodiversity dataset tracker, to track GenBank PLN sequence records and make them available for versioned archiving, and offline processing [@Poelen_2023_a].

The following script was used to track the GenBank PLN sequence records:

~~~
#!/bin/bash
#
# Lists Genbank Plant sequence entries (including fungi and algae)
#
# For more info, see https://ftp.ncbi.nlm.nih.gov/genbank/README.genbank 

preston track "https://ftp.ncbi.nlm.nih.gov/genbank/gbrel.txt"\
 | preston cat\
 | grep -oE "gbpln+[0-9]+[.]seq"\
 | sed 's+^+https://ftp.ncbi.nlm.nih.gov/genbank/+g'\
 | sed 's+$+.gz+g'
~~~

At the time, this produced a list of resources starting with:

~~~
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln10.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln100.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1000.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1001.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1002.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1003.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1004.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1005.seq.gz
https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1006.seq.gz
~~~

These files ending with ```seq.gz``` were then tracked using command like:

~~~
preston track https://ftp.ncbi.nlm.nih.gov/genbank/gbpln1.seq.gz
~~~

A Preston package was built using these "track" commands to document where and when genbank resources were accessed, and what they contained. In addition, copies of the resources were made. This package can be uniquely identified by the following content id:

~~~
hash://sha256/bc7368469e50020ce8ae27b9d6a9a869e0b9a2a0a9b5480c69ce6751fa4b870e
~~~

This resulting Preston package of GenBanks PLN division record was archived offline on an external harddisk and online at ASU's BioKiC (Biodiversity Knowledge integration Center) and made available via https://linker.bio . The total volume of the GenBank PLN records was a little over 200GB, small enough to fit on a personal computer, or external hard disk. 

#### Acquire and Version OBI Herbarium Specimen Records

Similarly, the OBI specimen records were tracked and archived using Preston [@Poelen_2023_b]. Then, this versioned and offline enabled archive was used to query for identifiers found in candidate records. 

For instance, GenBank accession record https://www.ncbi.nlm.nih.gov/nuccore/MT735455 references numbers like "2490" and "9031" (from OBI09031) extracted from their locus. These numbers are then used to select records that contain both via query:  

~~~
preston ls\
 --anchor hash://sha256/be5605e58d2644baedcb160604080d9f02ce528064b7fbb13a5b556dd55cfeb6\
 --remote https://linker.bio\
 --no-cache\
 | preston dwc-stream\
 --remote https://linker.bio\
 --no-cache\
 | grep -E "[^0-9a-zA-Z-](2490)[^0-9a-zA-Z]"\
 | grep -E "[^0-9a-zA-Z-](9031)[^0-9a-zA-Z]"
~~~

where the lines with "grep" in is select only records that have the specified number (e.g., 2490, 9031) where the characters preceding and following are *not* alphanumeric characters. In this example, on only a single record has both numbers in it.

### Phase 2. Propose OBI associated GenBank Records

Then the GenBank archive was processed to list all records that mention "OBI" in their (locus, voucher_specimen) descriptions using:

~~~
preston ls\
 --anchor hash://sha256/bc7368469e50020ce8ae27b9d6a9a869e0b9a2a0a9b5480c69ce6751fa4b870e\
 --remote https://linker.bio,https://zenodo.org/record/8117720/files/,https://biokic6.rc.asu.edu/preston/gbpln\
 --no-cache\
 | preston gb-stream\
 --remote https://linker.bio,https://zenodo.org/record/8117720/files/,https://biokic6.rc.asu.edu/preston/gbpln\
 --no-cache\
 | grep "OBI"
~~~

The first command (i.e., ```preston ls ... https://linker.bio```) lists the content of the package with id hash://sha256/bc7368469e50020ce8ae27b9d6a9a869e0b9a2a0a9b5480c69ce6751fa4b870e, and downloads the necessary data via https://linker.bio if needed. 

The second command (i.e., ```preston gb-stream```) analyzes the package content as a stream, and generates metadata objects for each genbank accession encountered.

The third command (i.e., ```grep "OBI"```) includes only those datadata records that contain "OBI".

## Results

### Capture GenBank Candidate Records

On processing millions of GenBank accession records, 256 candidate genbank accession records with mention of OBI were shared with Katelin Pearson for review. By selecting the PLN division (plants), and selecting the OBI institutions code, we reduced the search space by a couple of order of magnitudes. With only a few hundred records, Kateline Pearson, an OBI curator, was able to make the candidate GenBank accession records that likely referenced OBI specimen records (see [genbank-associations-mentioning-OBI.csv](./genbank-associations-mentioning-OBI.csv)  or associated [online sheet](https://docs.google.com/spreadsheets/d/1kXRi9zDCPNd_55IrOWDfUjvzLr7ZIEDwn_H2yvQd6gA/edit#gid=1944590275) for the table with manual review notes).

Following, Jorrit Poelen used the OBI preston archive and retrieved preserved specimen records that contained numbers and/or other identifying information (e.g., scientific name occurring in the genbank accession record) to select a candidate specimen record for each candidate accession record. In about 1.5 hours, he compiled this list of specimen record / accession records associations in the following format. 

| occid | url | resourcename | locus |
| --- | --- | --- | --- |
| 4060422 | https://www.ncbi.nlm.nih.gov/nuccore/MW025115 | GenBank Record | Fritillaria sp. SR-2020 voucher OBI161445 small subunit ribosomal RNA gene, partial sequence; internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence; and large subunit ribosomal RNA gene, partial sequence. |

### Curatorial Candidate Record Review 

With this information, Katelin Pearson, a OBI data curator, took about 15 minutes to annotate the specimen records in the CCH2 Symbiota database with their related GenBank Accession number. Most of this time was spent to convert the information provided by Jorrit Poelen into a more convenient format. The full table can be found in [Appendix A](#appendix-a) and the first two lines of the OBI genetics table can be found below. Here, the occid is the record number unique to the CCH2 Symbiota database, url is the reference a GenBank accession, resourcename is the type of resource that Symbiota understands, and locus the optional information supported by Symbiota to include in an associated sequence record.

### Adding GenBank Links to Symbiota Records

After Katelin Pearson upload the genbank link table into the CCH2 Symbiota database, she exported the updated records to the published DwC-A. Following, Jorrit Poelen tracked the updated version of the DwC-A and selected the records with associated GenBank sequence records. Following, he created a table (see [Appendix B.](#appendix-b)) including the reference to the original record, a web url to a html record page, and the associated genbank record annotations. The first three lines of Appendix B. can be found below.

| derivedFrom | reference | associatedSequences |
| --- | --- | --- |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L143 | https://cch2.org/portal/collections/individual/index.php?occid=163984 | Test, Test, URL test |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2361 | https://cch2.org/portal/collections/individual/index.php?occid=166203 | GenBank Record, Angelica hendersonii voucher Tracey & V. Call 2490 (OBI09031) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735455\|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765790\|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765975\|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766140 |

#### Comparing Example Record Before and After Record Linking

In our methods, we keep track of the versions of the datasets we work with. The OBI specimen records were versioned prior and after annotating OBI specimen records with their associated GenBank accessions. This means that the changes in the records, as published via the OBI DwC-A can be measured. 

To demonstrate the changes to a specific record related to our example specimen record OBI09031, please consider the record prior to annotating the association:

~~~
preston ls\
 --anchor hash://sha256/be5605e58d2644baedcb160604080d9f02ce528064b7fbb13a5b556dd55cfeb6\
 --remote https://linker.bio\
 --no-cache\
 | preston dwc-stream\
 --remote https://linker.bio\
 --no-cache\
 | grep -E "[^0-9a-zA-Z-](2490)[^0-9a-zA-Z]"\
 | grep -E "[^0-9a-zA-Z-](9031)[^0-9a-zA-Z]"\
 | tail -n1\
 | jq --raw-output '.["http://www.w3.org/ns/prov#wasDerivedFrom"]'
~~~

which points us to the versioned records with identifier:

`line:zip:hash://sha256/b60f9dd7868d6296ddea107219d41e5a92d55f1a5e0e5ee894c6e9977cb872cd!/occurrences.csv!/L2361`

The content associated with this content identifier can be retrieved via ```preston cat 'line:zip:hash://sha256/b60f9dd7868d6296ddea107219d41e5a92d55f1a5e0e5ee894c6e9977cb872cd!/occurrences.csv!/L1,L2361'``` or accessed via [OBI09031@b60f9.csv](https://linker.bio/line:zip:hash://sha256/b60f9dd7868d6296ddea107219d41e5a92d55f1a5e0e5ee894c6e9977cb872cd!/occurrences.csv!/L1,L2361).  

A textual representation of the record is shown below.

~~~
id                             166203
institutionCode                OBI
collectionCode                 
ownerInstitutionCode           
collectionID                   3818d95b-b6a4-11e8-b408-001a64db2964
basisOfRecord                  PreservedSpecimen
occurrenceID                   256368e3-f8d7-4028-8010-1a4ff3eb8111
catalogNumber                  
otherCatalogNumbers            9031
higherClassification           Organism|Plantae|Viridiplantae|Streptophyta|Embryophyta|Tracheophyta|Spermatophytina|Magnoliopsida|Asteranae|Apiales|Apiaceae|Angelica
kingdom                        Plantae
phylum                         Tracheophyta
class                          Magnoliopsida
order                          Apiales
family                         Apiaceae
scientificName                 Angelica hendersonii
taxonID                        210544
scientificNameAuthorship       Coult. & Rose
genus                          Angelica
subgenus                       
specificEpithet                hendersonii
verbatimTaxonRank              
infraspecificEpithet           
taxonRank                      Species
identifiedBy                   
dateIdentified                 
identificationReferences       
identificationRemarks          
taxonRemarks                   
identificationQualifier        
typeStatus                     
recordedBy                     Tracey Call; Viola Call
recordNumber                   2490
eventDate                      1966-07-05
year                           1966
month                          7
day                            5
startDayOfYear                 186
endDayOfYear                   
verbatimEventDate              5-Jul-66
occurrenceRemarks              
habitat                        Low bluffs
fieldNumber                    
eventID                        
informationWithheld            
dataGeneralizations            
dynamicProperties              
associatedOccurrences          herbariumSpecimenDuplicate: https://cch2.org/portal/collections/individual/index.php?guid=9afb4a2f-ac2a-4581-b339-9c394ed1163e | herbariumSpecimenDuplicate: https://cch2.org/portal/collections/individual/index.php?guid=1775039a-00d1-4cd3-b40a-3535c7863d93
associatedSequences            
associatedTaxa                 
reproductiveCondition          
establishmentMeans             
lifeStage                      
sex                            
individualCount                
preparations                   
locationID                     
continent                      
waterBody                      
islandGroup                    
island                         
country                        United States
stateProvince                  California
county                         Marin
municipality                   
locality                       North end of Tomales Bay and 2 mi south of Tomales
locationRemarks                
decimalLatitude                
decimalLongitude               
geodeticDatum                  
coordinateUncertaintyInMeters  
verbatimCoordinates            
georeferencedBy                
georeferenceProtocol           
georeferenceSources            
georeferenceVerificationStatus 
georeferenceRemarks            
minimumElevationInMeters       15
maximumElevationInMeters       
minimumDepthInMeters           
maximumDepthInMeters           
verbatimDepth                  
verbatimElevation              50ft.
disposition                    
language                       
recordEnteredBy                
modified                       2011-08-18 00:00:00
rights                         http://creativecommons.org/licenses/by-nc/4.0/
rightsHolder                   
accessRights                   
recordID                       9a370197-6899-4072-8b17-4f2f043fbd54
references                     https://cch2.org/portal/collections/individual/index.php?occid=166203
~~~

Similarly, the record seen after the annotation can be retrieved using:

~~~
preston ls\
 --anchor hash://sha256/be5605e58d2644baedcb160604080d9f02ce528064b7fbb13a5b556dd55cfeb6\
 --remote https://linker.bio\
 --no-cache\
 | preston dwc-stream\
 --remote https://linker.bio\
 --no-cache\
 | grep -E "[^0-9a-zA-Z-](2490)[^0-9a-zA-Z]"\
 | grep -E "[^0-9a-zA-Z-](9031)[^0-9a-zA-Z]"\
 | head -n1\
 | jq --raw-output '.["http://www.w3.org/ns/prov#wasDerivedFrom"]'
~~~

yielding: 

```line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L2361```
 

Now, we can use a text comparison between the two versioned records, using [diff](https://en.wikipedia.org/wiki/Diff), a widely available linux tool.


~~~
diff <(preston cat 'line:zip:hash://sha256/b60f9dd7868d6296ddea107219d41e5a92d55f1a5e0e5ee894c6e9977cb872cd!/occurrences.csv!/L1,L2361' | mlr --icsv --ojsonl cat ) <(preston cat 'line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2361' | mlr --icsv --ojsonl cat) 
~~~

which results in

~~~
50c50
<   "associatedSequences": "",
---
>   "associatedSequences": "GenBank Record, Angelica hendersonii voucher Tracey & V. Call 2490 (OBI09031) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735455|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765790|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765975|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766140",
~~~
: output of a commonly used programming tool `diff` as applied to our OBI09031 example.

![Output of a visual text comparison tool available via https://commontools.org as applied to our OBI09031 example.](visual-diff.png)

Additionally, you can find the before/after example records in json (i.e., [OBI09031-before.json](OBI09031-before.json)/ [OBI09031-after.json](OBI09031-after.json)) or csv (i.e., [OBI09031-before.csv](OBI09031-before.csv) / [OBI09031-after.csv](OBI09031-after.csv)) formats.

Finally, because we have our versioned records available in text formats, the options for re-use, archiving, or other subsequent processing are plentiful, and is consistent with one of the Unix principles [@McIlroy_1978]. 

> Expect the output of every program to become the input to another, as yet unknown, program. 

## Discussion

We took a systematic approach to independently track natural history collection records and sequence records. Then, we used regular expressions (or queries) to select candidate GenBank accession records. Following, after manual review of candidate records, we extracted identifiers and names to link locate their associated specimen records in the Hoover Herbarium collection as tracked. While the method is not fully automated, our method reduced the number of candidate accession records from millions to hundreds. This many order of magnitude reduction of candidates made manual review was feasible. We expect that periodic revisiting of the available records in GenBank will yield additional associated genbank records. Also, we hope that this example show that links between existing GenBank accessions and their specimen records can be found without major technological investment. And, we hope that this example will help inspire to develop best practices to place identifying information in GenBank records such that collection managers can somehwat easily locate sequences associated to the specimen they keep. 

## Appendix A

GenBank link table created by Katelin Pearson to link OBI specimen records to their associated GenBank sequences. 

See also [OBI_genetics.csv](./OBI_genetics.csv). 


| occid | url | resourcename | locus |
| --- | --- | --- | --- |
| 4060422 | https://www.ncbi.nlm.nih.gov/nuccore/MW025115 | GenBank Record | Fritillaria sp. SR-2020 voucher OBI161445 small subunit ribosomal RNA gene, partial sequence; internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence; and large subunit ribosomal RNA gene, partial sequence. |
| 2186655 | https://www.ncbi.nlm.nih.gov/nuccore/MF670383 | GenBank Record | Megalochlamys marlothii voucher Rodin 9194 (OBI) trnS-trnG intergenic spacer, partial sequence; chloroplast. |
| 2186655 | https://www.ncbi.nlm.nih.gov/nuccore/MF678400 | GenBank Record | Megalochlamys marlothii voucher Rodin 9194 (OBI) ribosomal protein S16 (rps16) gene, intron; chloroplast. |
| 2186655 | https://www.ncbi.nlm.nih.gov/nuccore/MF768302 | GenBank Record | Megalochlamys marlothii voucher Rodin 9194 (OBI) trnT-trnL intergenic spacer, partial sequence; chloroplast. |
| 2186655 | https://www.ncbi.nlm.nih.gov/nuccore/MF768361 | GenBank Record | Megalochlamys marlothii voucher Rodin 9194 (OBI) trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 2186655 | https://www.ncbi.nlm.nih.gov/nuccore/MF768408 | GenBank Record | Megalochlamys marlothii voucher Rodin 9194 (OBI) internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 214465 | https://www.ncbi.nlm.nih.gov/nuccore/MT735479 | GenBank Record | Angelica lucida voucher D. Smith 203 (OBI13881) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 214465 | https://www.ncbi.nlm.nih.gov/nuccore/MT765849 | GenBank Record | Angelica lucida D. Smith 203 (OBI13881) ndhF-rpl32 intergenic spacer, partial sequence. |
| 214465 | https://www.ncbi.nlm.nih.gov/nuccore/MT766044 | GenBank Record | Angelica lucida D. Smith 203 (OBI13881) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 214465 | https://www.ncbi.nlm.nih.gov/nuccore/MT766204 | GenBank Record | Angelica lucida D. Smith 203 (OBI13881) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 214463 | https://www.ncbi.nlm.nih.gov/nuccore/MT735449 | GenBank Record | Angelica scabrida voucher A.C. Sanders et al. 6885 (OBI044899) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 214463 | https://www.ncbi.nlm.nih.gov/nuccore/MT765845 | GenBank Record | Angelica scabrida A.C. Sanders et al. 6885 (OBI044899) ndhF-rpl32 intergenic spacer, partial sequence. |
| 214463 | https://www.ncbi.nlm.nih.gov/nuccore/MT766024 | GenBank Record | Angelica scabrida A.C. Sanders et al. 6885 (OBI044899) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 214463 | https://www.ncbi.nlm.nih.gov/nuccore/MT766162 | GenBank Record | Angelica scabrida A.C. Sanders et al. 6885 (OBI044899) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 211800 | https://www.ncbi.nlm.nih.gov/nuccore/MT735480 | GenBank Record | Angelica lucida voucher Tracey & V. Call 2507 (OBI081640) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 211800 | https://www.ncbi.nlm.nih.gov/nuccore/MT765854 | GenBank Record | Angelica lucida Tracey & V. Call 2507 (OBI081640) ndhF-rpl32 intergenic spacer, partial sequence. |
| 211800 | https://www.ncbi.nlm.nih.gov/nuccore/MT766050 | GenBank Record | Angelica lucida Tracey & V. Call 2507 (OBI081640) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 211800 | https://www.ncbi.nlm.nih.gov/nuccore/MT766205 | GenBank Record | Angelica lucida Tracey & V. Call 2507 (OBI081640) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 198762 | https://www.ncbi.nlm.nih.gov/nuccore/JF951103 | GenBank Record | Phalaris lemmonii isolate LEM25383 trnT-trnL intergenic spacer, partial sequence; tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; plastid. |
| 196156 | https://www.ncbi.nlm.nih.gov/nuccore/OK157416 | GenBank Record | Nemacladus secundiflorus var. secundiflorus voucher OBI:29532 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 196156 | https://www.ncbi.nlm.nih.gov/nuccore/OK136165 | GenBank Record | Nemacladus secundiflorus var. secundiflorus voucher OBI:DKeil29532 atpB-rbcL intergenic spacer region, partial sequence; chloroplast. |
| 184474 | https://www.ncbi.nlm.nih.gov/nuccore/MW025106 | GenBank Record | Fritillaria ojaiensis voucher OBI75168 small subunit ribosomal RNA gene, partial sequence; internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence; and large subunit ribosomal RNA gene, partial sequence. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN604492 | GenBank Record | Cirsium scariosum var. scariosum voucher OBI 60356 external transcribed spacer, partial sequence. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN604582 | GenBank Record | Cirsium scariosum var. scariosum voucher OBI 60356 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN604638 | GenBank Record | Cirsium scariosum var. scariosum voucher OBI 60356 maturase K (matK) gene, partial cds; chloroplast. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN617272 | GenBank Record | Cirsium scariosum var. scariosum voucher OBI 60356 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN617332 | GenBank Record | Cirsium scariosum var. scariosum voucher OBI 60356 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN604496 | GenBank Record | Cirsium undulatum voucher OBI 60365 external transcribed spacer, partial sequence. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN604610 | GenBank Record | Cirsium undulatum voucher OBI 60365 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN604651 | GenBank Record | Cirsium undulatum voucher OBI 60365 maturase K (matK) gene, partial cds; chloroplast. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN617276 | GenBank Record | Cirsium undulatum voucher OBI 60365 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175596 | https://www.ncbi.nlm.nih.gov/nuccore/MN617335 | GenBank Record | Cirsium undulatum voucher OBI 60365 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175592 | https://www.ncbi.nlm.nih.gov/nuccore/MN275437 | GenBank Record | Cirsium scariosum var. citrinum voucher OBI 29634F photosystem II protein D1 (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175592 | https://www.ncbi.nlm.nih.gov/nuccore/MN314906 | GenBank Record | Cirsium scariosum var. citrinum voucher OBI 29634F tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175592 | https://www.ncbi.nlm.nih.gov/nuccore/MN335162 | GenBank Record | Cirsium scariosum var. citrinum voucher OBI 29634F internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175592 | https://www.ncbi.nlm.nih.gov/nuccore/MN230952 | GenBank Record | Cirsium scariosum var. citrinum voucher OBI 29634F external transcribed spacer, partial sequence. |
| 175581 | https://www.ncbi.nlm.nih.gov/nuccore/MN604493 | GenBank Record | Cirsium scariosum var. toiyabense voucher OBI 60380 external transcribed spacer, partial sequence. |
| 175581 | https://www.ncbi.nlm.nih.gov/nuccore/MN604583 | GenBank Record | Cirsium scariosum var. toiyabense voucher OBI 60380 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175581 | https://www.ncbi.nlm.nih.gov/nuccore/MN604639 | GenBank Record | Cirsium scariosum var. toiyabense voucher OBI 60380 maturase K (matK) gene, partial cds; chloroplast. |
| 175581 | https://www.ncbi.nlm.nih.gov/nuccore/MN617273 | GenBank Record | Cirsium scariosum var. toiyabense voucher OBI 60380 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175581 | https://www.ncbi.nlm.nih.gov/nuccore/MN617333 | GenBank Record | Cirsium scariosum var. toiyabense voucher OBI 60380 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175526 | https://www.ncbi.nlm.nih.gov/nuccore/MN604487 | GenBank Record | Cirsium ochrocentrum voucher OBI 60392 external transcribed spacer, partial sequence. |
| 175526 | https://www.ncbi.nlm.nih.gov/nuccore/MN604571 | GenBank Record | Cirsium ochrocentrum voucher OBI 60392 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175526 | https://www.ncbi.nlm.nih.gov/nuccore/MN604674 | GenBank Record | Cirsium ochrocentrum voucher OBI 60392 maturase K (matK) gene, partial cds; chloroplast. |
| 175526 | https://www.ncbi.nlm.nih.gov/nuccore/MN617259 | GenBank Record | Cirsium ochrocentrum voucher OBI 60392 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175526 | https://www.ncbi.nlm.nih.gov/nuccore/MN617341 | GenBank Record | Cirsium ochrocentrum voucher OBI 60392 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175241 | https://www.ncbi.nlm.nih.gov/nuccore/MN230951 | GenBank Record | Cirsium fontinale var. campylon voucher OBI 27922 external transcribed spacer, partial sequence. |
| 175241 | https://www.ncbi.nlm.nih.gov/nuccore/MN275341 | GenBank Record | Cirsium fontinale var. campylon voucher OBI 27922 maturase K (matK) gene, partial cds; chloroplast. |
| 175241 | https://www.ncbi.nlm.nih.gov/nuccore/MN275438 | GenBank Record | Cirsium fontinale var. campylon voucher OBI 27922 photosystem II protein D1 (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175241 | https://www.ncbi.nlm.nih.gov/nuccore/MN314905 | GenBank Record | Cirsium fontinale var. campylon voucher OBI 27922 tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175241 | https://www.ncbi.nlm.nih.gov/nuccore/MN335163 | GenBank Record | Cirsium fontinale var. campylon voucher OBI 27922 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175241 | https://www.ncbi.nlm.nih.gov/nuccore/MN230952 | GenBank Record | Cirsium scariosum var. citrinum voucher OBI 29634F external transcribed spacer, partial sequence. |
| 175222 | https://www.ncbi.nlm.nih.gov/nuccore/MN604514 | GenBank Record | Cirsium eatonii var. eatonii voucher OBI 64116 external transcribed spacer, partial sequence. |
| 175222 | https://www.ncbi.nlm.nih.gov/nuccore/MN604550 | GenBank Record | Cirsium eatonii var. eatonii voucher OBI 64116 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175222 | https://www.ncbi.nlm.nih.gov/nuccore/MN604666 | GenBank Record | Cirsium eatonii var. eatonii voucher OBI 64116 maturase K (matK) gene, partial cds; chloroplast. |
| 175222 | https://www.ncbi.nlm.nih.gov/nuccore/MN617234 | GenBank Record | Cirsium eatonii var. eatonii voucher OBI 64116 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175222 | https://www.ncbi.nlm.nih.gov/nuccore/MN617310 | GenBank Record | Cirsium eatonii var. eatonii voucher OBI 64116 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175203 | https://www.ncbi.nlm.nih.gov/nuccore/MN230934 | GenBank Record | Cirsium cymosum var. canovirens voucher OBI 30302-8 external transcribed spacer, partial sequence. |
| 175203 | https://www.ncbi.nlm.nih.gov/nuccore/MN275314 | GenBank Record | Cirsium cymosum var. canovirens voucher OBI 30302-8 maturase K (matK) gene, partial cds; chloroplast. |
| 175203 | https://www.ncbi.nlm.nih.gov/nuccore/MN275448 | GenBank Record | Cirsium cymosum var. canovirens voucher OBI 30302-8 photosystem II protein D1 (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175203 | https://www.ncbi.nlm.nih.gov/nuccore/MN314894 | GenBank Record | Cirsium cymosum var. canovirens voucher OBI 30302-8 tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175203 | https://www.ncbi.nlm.nih.gov/nuccore/MN335114 | GenBank Record | Cirsium cymosum var. canovirens voucher OBI 30302-8 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175187 | https://www.ncbi.nlm.nih.gov/nuccore/MN604465 | GenBank Record | Cirsium eatonii var. clokeyi voucher OBI 62978 external transcribed spacer, partial sequence. |
| 175187 | https://www.ncbi.nlm.nih.gov/nuccore/MN604549 | GenBank Record | Cirsium eatonii var. clokeyi voucher OBI 62978 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175187 | https://www.ncbi.nlm.nih.gov/nuccore/MN604665 | GenBank Record | Cirsium eatonii var. clokeyi voucher OBI 62978 maturase K (matK) gene, partial cds; chloroplast. |
| 175187 | https://www.ncbi.nlm.nih.gov/nuccore/MN617233 | GenBank Record | Cirsium eatonii var. clokeyi voucher OBI 62978 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175187 | https://www.ncbi.nlm.nih.gov/nuccore/MN617309 | GenBank Record | Cirsium eatonii var. clokeyi voucher OBI 62978 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175185 | https://www.ncbi.nlm.nih.gov/nuccore/MN604450 | GenBank Record | Cirsium ciliolatum voucher OBI 60321 external transcribed spacer, partial sequence. |
| 175185 | https://www.ncbi.nlm.nih.gov/nuccore/MN604539 | GenBank Record | Cirsium ciliolatum voucher OBI 60321 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175185 | https://www.ncbi.nlm.nih.gov/nuccore/MN604661 | GenBank Record | Cirsium ciliolatum voucher OBI 60321 maturase K (matK) gene, partial cds; chloroplast. |
| 175185 | https://www.ncbi.nlm.nih.gov/nuccore/MN617219 | GenBank Record | Cirsium ciliolatum voucher OBI 60321 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175185 | https://www.ncbi.nlm.nih.gov/nuccore/MN617296 | GenBank Record | Cirsium ciliolatum voucher OBI 60321 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 175101 | https://www.ncbi.nlm.nih.gov/nuccore/MN604445 | GenBank Record | Cirsium arizonicum var. tenuisectum voucher OBI 62969 external transcribed spacer, partial sequence. |
| 175101 | https://www.ncbi.nlm.nih.gov/nuccore/MN604609 | GenBank Record | Cirsium arizonicum var. tenuisectum voucher OBI 62969 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence. |
| 175101 | https://www.ncbi.nlm.nih.gov/nuccore/MN604612 | GenBank Record | Cirsium arizonicum var. tenuisectum voucher OBI 62969 maturase K (matK) gene, partial cds; chloroplast. |
| 175101 | https://www.ncbi.nlm.nih.gov/nuccore/MN617214 | GenBank Record | Cirsium arizonicum var. tenuisectum voucher OBI 62969 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast. |
| 175101 | https://www.ncbi.nlm.nih.gov/nuccore/MN617291 | GenBank Record | Cirsium arizonicum var. tenuisectum voucher OBI 62969 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast. |
| 166210 | https://www.ncbi.nlm.nih.gov/nuccore/MT735442 | GenBank Record | Angelica lineariloba voucher Tracey & V. Call 2043 (OBI081607) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 166210 | https://www.ncbi.nlm.nih.gov/nuccore/MT765840 | GenBank Record | Angelica lineariloba Tracey & V. Call 2043 (OBI081607) ndhF-rpl32 intergenic spacer, partial sequence. |
| 166210 | https://www.ncbi.nlm.nih.gov/nuccore/MT766019 | GenBank Record | Angelica lineariloba Tracey & V. Call 2043 (OBI081607) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 166210 | https://www.ncbi.nlm.nih.gov/nuccore/MT766157 | GenBank Record | Angelica lineariloba Tracey & V. Call 2043 (OBI081607) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 166209 | https://www.ncbi.nlm.nih.gov/nuccore/MT735448 | GenBank Record | Angelica lineariloba voucher Tracey & V. Call 2321 (OBI09033) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 166209 | https://www.ncbi.nlm.nih.gov/nuccore/MT765844 | GenBank Record | Angelica lineariloba Tracey & V. Call 2321 (OBI09033) ndhF-rpl32 intergenic spacer, partial sequence. |
| 166209 | https://www.ncbi.nlm.nih.gov/nuccore/MT766023 | GenBank Record | Angelica lineariloba Tracey & V. Call 2321 (OBI09033) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 166209 | https://www.ncbi.nlm.nih.gov/nuccore/MT766159 | GenBank Record | Angelica lineariloba Tracey & V. Call 2321 (OBI09033) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 166208 | https://www.ncbi.nlm.nih.gov/nuccore/MT707551 | GenBank Record | Lomatium dissectum voucher D. Keilet al. 30299 (OBI068349) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 166208 | https://www.ncbi.nlm.nih.gov/nuccore/MT765778 | GenBank Record | Lomatium dissectum D. Keilet al. 30299 (OBI068349) ndhF-rpl32 intergenic spacer, partial sequence. |
| 166208 | https://www.ncbi.nlm.nih.gov/nuccore/MT766091 | GenBank Record | Lomatium dissectum D. Keilet al. 30299 (OBI068349) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 166208 | https://www.ncbi.nlm.nih.gov/nuccore/MT766279 | GenBank Record | Lomatium dissectum D. Keilet al. 30299 (OBI068349) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 166207 | https://www.ncbi.nlm.nih.gov/nuccore/MT735443 | GenBank Record | Angelica lineariloba voucher D. Keil 21070 (OBI071409) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 166207 | https://www.ncbi.nlm.nih.gov/nuccore/MT765841 | GenBank Record | Angelica lineariloba D. Keil 21070 (OBI071409) ndhF-rpl32 intergenic spacer, partial sequence. |
| 166207 | https://www.ncbi.nlm.nih.gov/nuccore/MT766022 | GenBank Record | Angelica lineariloba D. Keil 21070 (OBI071409) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 166207 | https://www.ncbi.nlm.nih.gov/nuccore/MT766158 | GenBank Record | Angelica lineariloba D. Keil 21070 (OBI071409) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 166204 | https://www.ncbi.nlm.nih.gov/nuccore/MT735454 | GenBank Record | Angelica hendersonii voucher Tracey & V. Call 2071 (OBI09030) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 166204 | https://www.ncbi.nlm.nih.gov/nuccore/MT765781 | GenBank Record | Angelica hendersonii Tracey & V. Call 2071 (OBI09030) ndhF-rpl32 intergenic spacer, partial sequence. |
| 166204 | https://www.ncbi.nlm.nih.gov/nuccore/MT765974 | GenBank Record | Angelica hendersonii Tracey & V. Call 2071 (OBI09030) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 166204 | https://www.ncbi.nlm.nih.gov/nuccore/MT766139 | GenBank Record | Angelica hendersonii Tracey & V. Call 2071 (OBI09030) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |
| 166203 | https://www.ncbi.nlm.nih.gov/nuccore/MT735455 | GenBank Record | Angelica hendersonii voucher Tracey & V. Call 2490 (OBI09031) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence. |
| 166203 | https://www.ncbi.nlm.nih.gov/nuccore/MT765790 | GenBank Record | Angelica hendersonii Tracey & V. Call 2490 (OBI09031) ndhF-rpl32 intergenic spacer, partial sequence. |
| 166203 | https://www.ncbi.nlm.nih.gov/nuccore/MT765975 | GenBank Record | Angelica hendersonii Tracey & V. Call 2490 (OBI09031) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence. |
| 166203 | https://www.ncbi.nlm.nih.gov/nuccore/MT766140 | GenBank Record | Angelica hendersonii Tracey & V. Call 2490 (OBI09031) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence. |


## Appendix B 

References to specimen records with associated sequences after application of links of Appendix A.

generated using:

```bash
preston cat\
 --remote https://linker.bio\
 hash://sha256/be5605e58d2644baedcb160604080d9f02ce528064b7fbb13a5b556dd55cfeb6\
 | preston dwc-stream\
 | jq -c 'select(.["http://rs.tdwg.org/dwc/terms/associatedSequences"] != null)'\
 | jq '{ derivedFrom: .["http://www.w3.org/ns/prov#wasDerivedFrom"], reference: .["http://purl.org/dc/terms/references"], associatedSequences: .["http://rs.tdwg.org/dwc/terms/associatedSequences"] }'\
 | sed 's+line:zip+https://linker.bio/line:zip+g'\
 | sed 's+occurrences.csv!/+occurrences.csv!/L1,+g'\ 
 | mlr --ijson --ocsv cat
```

See also [specimen-record-with-associated-sequences.csv](./specimen-record-with-associated-sequences.csv).

| derivedFrom | reference | associatedSequences |
| --- | --- | --- |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L143 | https://cch2.org/portal/collections/individual/index.php?occid=163984 | Test, Test, URL test |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2361 | https://cch2.org/portal/collections/individual/index.php?occid=166203 | GenBank Record, Angelica hendersonii voucher Tracey & V. Call 2490 (OBI09031) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735455\|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765790\|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765975\|GenBank Record, Angelica hendersonii Tracey & V. Call 2490 (OBI09031) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766140 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2362 | https://cch2.org/portal/collections/individual/index.php?occid=166204 | GenBank Record, Angelica hendersonii voucher Tracey & V. Call 2071 (OBI09030) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735454\|GenBank Record, Angelica hendersonii Tracey & V. Call 2071 (OBI09030) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765781\|GenBank Record, Angelica hendersonii Tracey & V. Call 2071 (OBI09030) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765974\|GenBank Record, Angelica hendersonii Tracey & V. Call 2071 (OBI09030) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766139 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2365 | https://cch2.org/portal/collections/individual/index.php?occid=166207 | GenBank Record, Angelica lineariloba voucher D. Keil 21070 (OBI071409) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735443\|GenBank Record, Angelica lineariloba D. Keil 21070 (OBI071409) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765841\|GenBank Record, Angelica lineariloba D. Keil 21070 (OBI071409) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766022\|GenBank Record, Angelica lineariloba D. Keil 21070 (OBI071409) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766158 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2366 | https://cch2.org/portal/collections/individual/index.php?occid=166208 | GenBank Record, Lomatium dissectum voucher D. Keilet al. 30299 (OBI068349) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT707551\|GenBank Record, Lomatium dissectum D. Keilet al. 30299 (OBI068349) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765778\|GenBank Record, Lomatium dissectum D. Keilet al. 30299 (OBI068349) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766091\|GenBank Record, Lomatium dissectum D. Keilet al. 30299 (OBI068349) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766279 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2367 | https://cch2.org/portal/collections/individual/index.php?occid=166209 | GenBank Record, Angelica lineariloba voucher Tracey & V. Call 2321 (OBI09033) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735448\|GenBank Record, Angelica lineariloba Tracey & V. Call 2321 (OBI09033) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765844\|GenBank Record, Angelica lineariloba Tracey & V. Call 2321 (OBI09033) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766023\|GenBank Record, Angelica lineariloba Tracey & V. Call 2321 (OBI09033) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766159 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L2368 | https://cch2.org/portal/collections/individual/index.php?occid=166210 | GenBank Record, Angelica lineariloba voucher Tracey & V. Call 2043 (OBI081607) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735442\|GenBank Record, Angelica lineariloba Tracey & V. Call 2043 (OBI081607) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765840\|GenBank Record, Angelica lineariloba Tracey & V. Call 2043 (OBI081607) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766019\|GenBank Record, Angelica lineariloba Tracey & V. Call 2043 (OBI081607) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766157 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11177 | https://cch2.org/portal/collections/individual/index.php?occid=175101 | GenBank Record, Cirsium arizonicum var. tenuisectum voucher OBI 62969 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604445\|GenBank Record, Cirsium arizonicum var. tenuisectum voucher OBI 62969 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604609\|GenBank Record, Cirsium arizonicum var. tenuisectum voucher OBI 62969 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604612\|GenBank Record, Cirsium arizonicum var. tenuisectum voucher OBI 62969 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617214\|GenBank Record, Cirsium arizonicum var. tenuisectum voucher OBI 62969 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617291 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11261 | https://cch2.org/portal/collections/individual/index.php?occid=175185 | GenBank Record, Cirsium ciliolatum voucher OBI 60321 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604450\|GenBank Record, Cirsium ciliolatum voucher OBI 60321 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604539\|GenBank Record, Cirsium ciliolatum voucher OBI 60321 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604661\|GenBank Record, Cirsium ciliolatum voucher OBI 60321 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617219\|GenBank Record, Cirsium ciliolatum voucher OBI 60321 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617296 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11263 | https://cch2.org/portal/collections/individual/index.php?occid=175187 | GenBank Record, Cirsium eatonii var. clokeyi voucher OBI 62978 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604465\|GenBank Record, Cirsium eatonii var. clokeyi voucher OBI 62978 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604549\|GenBank Record, Cirsium eatonii var. clokeyi voucher OBI 62978 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604665\|GenBank Record, Cirsium eatonii var. clokeyi voucher OBI 62978 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617233\|GenBank Record, Cirsium eatonii var. clokeyi voucher OBI 62978 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617309 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11279 | https://cch2.org/portal/collections/individual/index.php?occid=175203 | GenBank Record, Cirsium cymosum var. canovirens voucher OBI 30302-8 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN230934\|GenBank Record, Cirsium cymosum var. canovirens voucher OBI 30302-8 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN275314\|GenBank Record, Cirsium cymosum var. canovirens voucher OBI 30302-8 photosystem II protein D1 (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN275448\|GenBank Record, Cirsium cymosum var. canovirens voucher OBI 30302-8 tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN314894\|GenBank Record, Cirsium cymosum var. canovirens voucher OBI 30302-8 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN335114 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11298 | https://cch2.org/portal/collections/individual/index.php?occid=175222 | GenBank Record, Cirsium eatonii var. eatonii voucher OBI 64116 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604514\|GenBank Record, Cirsium eatonii var. eatonii voucher OBI 64116 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604550\|GenBank Record, Cirsium eatonii var. eatonii voucher OBI 64116 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604666\|GenBank Record, Cirsium eatonii var. eatonii voucher OBI 64116 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617234\|GenBank Record, Cirsium eatonii var. eatonii voucher OBI 64116 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617310 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11317 | https://cch2.org/portal/collections/individual/index.php?occid=175241 | GenBank Record, Cirsium fontinale var. campylon voucher OBI 27922 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN230951\|GenBank Record, Cirsium scariosum var. citrinum voucher OBI 29634F external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN230952\|GenBank Record, Cirsium fontinale var. campylon voucher OBI 27922 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN275341\|GenBank Record, Cirsium fontinale var. campylon voucher OBI 27922 photosystem II protein D1 (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN275438\|GenBank Record, Cirsium fontinale var. campylon voucher OBI 27922 tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN314905\|GenBank Record, Cirsium fontinale var. campylon voucher OBI 27922 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN335163 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11602 | https://cch2.org/portal/collections/individual/index.php?occid=175526 | GenBank Record, Cirsium ochrocentrum voucher OBI 60392 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604487\|GenBank Record, Cirsium ochrocentrum voucher OBI 60392 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604571\|GenBank Record, Cirsium ochrocentrum voucher OBI 60392 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604674\|GenBank Record, Cirsium ochrocentrum voucher OBI 60392 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617259\|GenBank Record, Cirsium ochrocentrum voucher OBI 60392 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617341 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11656 | https://cch2.org/portal/collections/individual/index.php?occid=175581 | GenBank Record, Cirsium scariosum var. toiyabense voucher OBI 60380 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604493\|GenBank Record, Cirsium scariosum var. toiyabense voucher OBI 60380 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604583\|GenBank Record, Cirsium scariosum var. toiyabense voucher OBI 60380 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604639\|GenBank Record, Cirsium scariosum var. toiyabense voucher OBI 60380 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617273\|GenBank Record, Cirsium scariosum var. toiyabense voucher OBI 60380 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617333 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11667 | https://cch2.org/portal/collections/individual/index.php?occid=175592 | GenBank Record, Cirsium scariosum var. citrinum voucher OBI 29634F external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN230952\|GenBank Record, Cirsium scariosum var. citrinum voucher OBI 29634F photosystem II protein D1 (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN275437\|GenBank Record, Cirsium scariosum var. citrinum voucher OBI 29634F tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN314906\|GenBank Record, Cirsium scariosum var. citrinum voucher OBI 29634F internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN335162 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L11671 | https://cch2.org/portal/collections/individual/index.php?occid=175596 | GenBank Record, Cirsium scariosum var. scariosum voucher OBI 60356 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604492\|GenBank Record, Cirsium undulatum voucher OBI 60365 external transcribed spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604496\|GenBank Record, Cirsium scariosum var. scariosum voucher OBI 60356 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604582\|GenBank Record, Cirsium undulatum voucher OBI 60365 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MN604610\|GenBank Record, Cirsium scariosum var. scariosum voucher OBI 60356 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604638\|GenBank Record, Cirsium undulatum voucher OBI 60365 maturase K (matK) gene, partial cds; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN604651\|GenBank Record, Cirsium scariosum var. scariosum voucher OBI 60356 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617272\|GenBank Record, Cirsium undulatum voucher OBI 60365 psbA (psbA) gene, partial cds; psbA-trnH intergenic spacer, complete sequence; and tRNA-His (trnH) gene, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617276\|GenBank Record, Cirsium scariosum var. scariosum voucher OBI 60356 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617332\|GenBank Record, Cirsium undulatum voucher OBI 60365 tRNA-Leu (trnL) gene and trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MN617335 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L20543 | https://cch2.org/portal/collections/individual/index.php?occid=184474 | GenBank Record, Fritillaria ojaiensis voucher OBI75168 small subunit ribosomal RNA gene, partial sequence; internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence; and large subunit ribosomal RNA gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MW025106 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L32222 | https://cch2.org/portal/collections/individual/index.php?occid=196156 | GenBank Record, Nemacladus secundiflorus var. secundiflorus voucher OBI:DKeil29532 atpB-rbcL intergenic spacer region, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/OK136165\|GenBank Record, Nemacladus secundiflorus var. secundiflorus voucher OBI:29532 internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/OK157416 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L34811 | https://cch2.org/portal/collections/individual/index.php?occid=198762 | Phalaris lemmonii isolate LEM25383ITS3, internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence, https://www.ncbi.nlm.nih.gov/nuccore/JF951067\|GenBank Record, Phalaris lemmonii isolate LEM25383 trnT-trnL intergenic spacer, partial sequence; tRNA-Leu (trnL) gene, complete sequence; and trnL-trnF intergenic spacer, partial sequence; plastid., https://www.ncbi.nlm.nih.gov/nuccore/JF951103 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L47836 | https://cch2.org/portal/collections/individual/index.php?occid=211800 | GenBank Record, Angelica lucida voucher Tracey & V. Call 2507 (OBI081640) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735480\|GenBank Record, Angelica lucida Tracey & V. Call 2507 (OBI081640) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765854\|GenBank Record, Angelica lucida Tracey & V. Call 2507 (OBI081640) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766050\|GenBank Record, Angelica lucida Tracey & V. Call 2507 (OBI081640) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766205 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L50378 | https://cch2.org/portal/collections/individual/index.php?occid=214463 | GenBank Record, Angelica scabrida voucher A.C. Sanders et al. 6885 (OBI044899) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735449\|GenBank Record, Angelica scabrida A.C. Sanders et al. 6885 (OBI044899) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765845\|GenBank Record, Angelica scabrida A.C. Sanders et al. 6885 (OBI044899) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766024\|GenBank Record, Angelica scabrida A.C. Sanders et al. 6885 (OBI044899) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766162 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L50380 | https://cch2.org/portal/collections/individual/index.php?occid=214465 | GenBank Record, Angelica lucida voucher D. Smith 203 (OBI13881) internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT735479\|GenBank Record, Angelica lucida D. Smith 203 (OBI13881) ndhF-rpl32 intergenic spacer, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT765849\|GenBank Record, Angelica lucida D. Smith 203 (OBI13881) tRNA-Asp (trnD-GUC), tRNA-Tyr (trnY-GUA), tRNA-Glu (trnE-UUC), and tRNA-Thr (trnT-GGU) genes, complete sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766044\|GenBank Record, Angelica lucida D. Smith 203 (OBI13881) rpl32-trnL intergenic spacer and tRNA-Leu (trnL) gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MT766204 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L56777 | https://cch2.org/portal/collections/individual/index.php?occid=2186655 | GenBank Record, Megalochlamys marlothii voucher Rodin 9194 (OBI) trnS-trnG intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MF670383\|GenBank Record, Megalochlamys marlothii voucher Rodin 9194 (OBI) ribosomal protein S16 (rps16) gene, intron; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MF678400\|GenBank Record, Megalochlamys marlothii voucher Rodin 9194 (OBI) trnT-trnL intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MF768302\|GenBank Record, Megalochlamys marlothii voucher Rodin 9194 (OBI) trnL-trnF intergenic spacer, partial sequence; chloroplast., https://www.ncbi.nlm.nih.gov/nuccore/MF768361\|GenBank Record, Megalochlamys marlothii voucher Rodin 9194 (OBI) internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, complete sequence; and internal transcribed spacer 2, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MF768408 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L81830 | https://cch2.org/portal/collections/individual/index.php?occid=4060422 | GenBank Record, Fritillaria sp. SR-2020 voucher OBI161445 small subunit ribosomal RNA gene, partial sequence; internal transcribed spacer 1, 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence; and large subunit ribosomal RNA gene, partial sequence., https://www.ncbi.nlm.nih.gov/nuccore/MW025115 |
| https://linker.bio/line:zip:hash://sha256/cd9de973510975dac3394952bba9c486a482762b3beab05ecb678037b99ab85b!/occurrences.csv!/L1,L87400 | null | Abronia pogonantha |
