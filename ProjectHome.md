In Europe it is important to retain interoperability of Metadata Discovery Services with the INSPIRE Metadata Rules (RD3) and the INSPIRE Discovery Service (DS) (RD5).
The INSPIRE DS (RD5) are currently defined as a slightly extended version (profile) of the CSW ISO (RD6). For establishing interoperability between the I15 EP (RD7) and the INSPIRE\_DS the document (RD2) defines the required concepts (done within the ESA HMA-T project in 2008-2009). One result of (RD2) is the definition of an “INSPIRE Conformance Class” (ICC) of the I15 EP which restricts the amount of ExtrinsicObjects, Associations, Slots and query capabilities by simultaneously retaining the semantics to that supported within the INSPIRE Discovery Services.
Interoperability between INSPIRE DS and I15 EP (ICC) concerns:
1.	An INSPIRE\_DS client accessing a I15 EP (ICC) service
2.	A I15 EP (ICC) client accessing an INSPIRE\_DS service
Both targets require the translation of the client-request into the request information model of the server and vice versa the translation of the server response into the information model of the client. These translations are subject of this Transformation Module.

(RD2)	INSPIRE Conformance Class of OGC I15 (ISO19115 Metadata) Extension Package of CS-W ebRIM Profile - I15 EP Protocol Binding of INSPIRE Discovery Services – OGC 08-197r3, https://wiki.services.eoportal.org/tiki-download_file.php?fileId=535.
(RD3)	INSPIRE, INS MD, Draft Implementing Rules for Metadata, version 4.1, 2008-01-29, http://inspire.ec.europa.eu/index.cfm/pageid/101.
(RD4)	INSPIRE Metadata Implementing Rules: Technical Guidelines based on EN ISO 19115 and EN ISO 19119, European Commission Joint Research Centre, 16-06-2010, http://inspire.ec.europa.eu/index.cfm/pageid/101.
(RD5)	Technical Guidance for INSPIRE Discovery Services, Drafting Team Network Services, 22-07-2009, http://inspire.ec.europa.eu/index.cfm/pageid/5.
(RD6)	OpenGIS Catalogue Services Specification 2.0.2 – ISO Metadata Application Profile, OGC 07-045, Version 1.0, 19/07/2007, http://portal.opengeospatial.org/files/?artifact_id=21460
(RD7)	OGC© I15 (ISO19115 Metadata) Extension Package of CS-W ebRIM Profile 1.0, OGC 13-084r2, Version 1.0.0, 16/01/2014, https://portal.opengeospatial.org/files/?artifact_id=56905.