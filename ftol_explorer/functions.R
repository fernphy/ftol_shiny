#' Get useful information about accessions for a species in FTOL
#'
#' @param species_select Species name.
#' @param accessions_long Dataframe of accessions used in FTOL, long format
#'   (one row per accession).
#' @param accessions_wide Dataframe of accessions used in FTOL, wide format
#'   (one row per species).
#' @param match_results_resolved_all Dataframe with results of resolving
#'   NCBI taxonomic names to pteridocat.
#'
#' @return Tibble
#'
get_acc_info <- function(species_select,
                         accessions_long,
                         accessions_wide,
                         match_results_resolved_all) {
  # return empty tibble if no valid species is selected
  if (length(species_select) < 1) {
    return(tibble::tibble())
  }
  if (!species_select %in% accessions_long$species) {
    return(tibble::tibble())
  }

  match_results_resolved_all <-
    match_results_resolved_all %>%
    mutate(ncbi_taxid = parse_number(taxid)) %>%
    assert(not_na, ncbi_taxid) %>%
    select(-taxid)

  acc_tax_data <-
    accessions_long %>%
    filter(species == species_select) %>%
    select(-contains("_name"), -outgroup, -species) %>%
    left_join(
      select(
        match_results_resolved_all,
        query, matched_name, resolved_name,
        matched_status, match_type, ncbi_taxid
      ),
      by = "ncbi_taxid"
    ) %>%
    mutate(
      accession = glue::glue(
        '<a href="https://www.ncbi.nlm.nih.gov/nuccore/{accession}" target="_blank">{accession}</a>' # nolint
      ),
      ncbi_taxid = glue::glue(
        '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id={ncbi_taxid}" target="_blank">{ncbi_taxid}</a>' # nolint
      )
    ) %>%
    arrange(locus)

  acc_data <-
    acc_tax_data %>%
    select(locus, accession, seq_len)

  taxonomy_data <-
    acc_tax_data %>%
    select(
      accession, ncbi_taxid, query, matched_name,
      resolved_name, matched_status, match_type
    )

  taxonomy_data_simple <- taxonomy_data %>%
    select(-accession) %>%
    unique()

  if (nrow(taxonomy_data_simple) == 1) {
    taxonomy_data <- taxonomy_data_simple
  }

  voucher_data <-
    accessions_wide %>%
    filter(species == species_select) %>%
    select(c(join_by, specimen_voucher, publication, outgroup))

  list(
    acc_data = acc_data,
    voucher_data = voucher_data,
    taxonomy_data = taxonomy_data
  )
}

#' Make a URL string for searching a taxonium tree
#' @param base_url Basic URL for the taxonium tree
#' @param species Name of species to search
#' @return Link with URL to tree with search results for species
make_tree_search_url <- function(base_url, species) {
paste0(
    base_url,
    "&srch=%5B%7B%22key%22%3A%22aa1%22%2C%22type%22%3A%22name%22%2C%22method%22%3A%22text_match%22%2C%22text%22%3A%22", # nolint
    species,
    "%22%2C%22gene%22%3A%22S%22%2C%22position%22%3A484%2C%22new_residue%22%3A%22any%22%2C%22min_tips%22%3A0%7D%5D&zoomToSearch=0" # nolint
  )
}
