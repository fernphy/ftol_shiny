create_link <- function(val) {
    glue::glue(
      '<a href="https://www.ncbi.nlm.nih.gov/nuccore/{val}" target="_blank">{val}</a>' # nolint
    )
}

# target="_blank" class="btn btn-primary"

#' Get useful information about accessions for a species in FTOL
#'
#' @param species_select Species name.
#' @param sanger_accessions_selection Dataframe of accessions used in FTOL.
#' @param ncbi_accepted_names_map Dataframe mapping NCBI taxid to resolved
#'   name from pteridocat.
#' @param match_results_resolved_all Dataframe with results of resolving
#'   NCBI taxonomic names to pteridocat.
#'
#' @return Tibble
#'
get_acc_info <- function(
  species_select,
  sanger_accessions_selection,
  ncbi_accepted_names_map,
  match_results_resolved_all) {
  if (length(species_select) < 1) {
    return(tibble::tibble())
  }
  if (!species_select %in% sanger_accessions_selection$species) {
    return(tibble::tibble())
  }
  sanger_accessions_selection %>%
    filter(species == species_select) %>%
    mutate(across(contains("seq_len"), as.character)) %>%
    left_join(
      unique(select(ncbi_accepted_names_map, species, taxid, resolved_name)),
      by = "species"
    ) %>%
    left_join(
      select(match_results_resolved_all, -taxid), by = "resolved_name"
    ) %>%
    pivot_longer(everything()) %>%
    mutate(value = as.character(value)) %>%
    filter(!is.na(value)) %>%
    filter(value != "0") %>%
    mutate(
      value = case_when(
        str_detect(name, "accession") ~ create_link(value),
        TRUE ~ value
      )
    )
  }

