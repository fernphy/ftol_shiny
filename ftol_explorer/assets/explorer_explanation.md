## Getting started

Start by selecting a species from the drop-down menu on the left.

You can also type into the search box and it will auto-complete.

## Data panels

### Accession

This panel shows one row per accession for the selected species. 

Columns:
- **locus**: Name of locus (gene or region)
- **accession**: GenBank accession number; clicking will open a browser tab with that accession in GenBank.
- **seq_len**: Length of the sequence in basepairs.

### Voucher

This panel has only one row.

Columns:
- **join_by**: Method used to join sequences across loci within the species.
- **specimen_voucher**: Specimen voucher, converted to all lowercase and with spaces and punctuation removed to allow for matching.
- **publication**: Publication for the accession(s).
- **outgroup**: TRUE if species is in outgroup (non-ferns); FALSE if not (ferns)

### Taxonomy

This panel may have just one row if the data are the same for all accessions, or one row per accession if different accessions have different data.

Columns:
- **accession**: GenBank accession number; clicking will open a browser tab with that accession in GenBank. Only appears if different accessions have different data.
- **ncbi_taxid**: NCBI taxonomic ID for the accession (or species). Clicking on the ID number will open a browser tab with that ID in the NCBI Taxonomy database.
- **query**: NCBI species name of accession used as query for name resolution.
- **matched_name**: Name matched by [taxastand](https://github.com/joelnitta/taxastand) when querying NCBI name against [pteridocat](https://github.com/fernphy/pteridocat) taxonomic database.
- **resolved_name**: The name ultimately used for FTOL; if the match was a synonym, the resolved name is the accepted name.
- **matched_status**: Taxonomic status of the matched name (typically, either "accepted" or "synonym").
- **match_type**: Type of match. For more information, see the [taxastand vignette](https://joelnitta.github.io/taxastand/articles/basics.html#name-matching).