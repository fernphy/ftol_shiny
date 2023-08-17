library(jsontools)
library(shiny)
library(shiny.react)
library(shiny.fluent)
library(tidyverse)
library(assertr)
library(markdown)
library(ftolr)

# Setup ----

source("functions.R")

species <- sort(ftolr::accessions_wide$species)

species_options <- NULL
for (i in seq_along(species)) {
  species_options[[i]] <- list(key = species[[i]], text = species[[i]])
}

data_table_settings <- list(
      dom = "t",
      ordering = FALSE,
      paging = FALSE,
      searching = FALSE
    )

# tree link
# For some reason using the JSON config directly in taxonium isn't working,
# so add it to the URL (custom config option 1)
# https://docs.taxonium.org/en/latest/advanced.html#custom-configuration
config_url <- "https://raw.githubusercontent.com/fernphy/ftol_vis/main/_targets/user/taxonium/ftol_config.json" # nolint

config_string <- jsonlite::read_json(config_url) |>
  jsontools::format_json(auto_unbox = TRUE) |>
  as.character() |>
  stringr::str_remove_all("\\[|\\]")

base_url <- "https://taxonium.org/?treeUrl=https%3A%2F%2Fraw.githubusercontent.com%2Ffernphy%2Fftol_vis%2Fmain%2F_targets%2Fuser%2Ftaxonium%2Fftol_tree.tree&ladderizeTree=true&treeType=nwk&metaUrl=https%3A%2F%2Fraw.githubusercontent.com%2Ffernphy%2Fftol_vis%2Fmain%2F_targets%2Fuser%2Ftaxonium%2Fftol_data.csv&metaType=meta_csv&xType=x_dist&color=%7B%22field%22%3A%22meta_family%22%7D" # nolint

base_url <- glue::glue("{base_url}&config={config_string}")

# UI ----

ui <- fluidPage(

  titlePanel("FTOL explorer"),

  sidebarLayout(

    # Sidebar with input selection box for species
    sidebarPanel(
      h4(paste0("FTOL v", ftolr::ft_data_ver())),
      # Use combo-box input for autocomplete
      ComboBox.shinyInput("combo", value = list(text = species[[1]]),
        options = species_options, allowFreeform = TRUE
      )
    ),
    # Main panel with output in three panels
    mainPanel(

      tabsetPanel(
        tabPanel(
          "Data",
          fluidRow(
            column(6,
              markdown("### Accession"),
              dataTableOutput("acc_data")
            )
          ),
          fluidRow(
            column(8,
              markdown("### Voucher"),
              dataTableOutput("voucher_data")
            )
          ),
          fluidRow(
            column(12,
              markdown("### Taxonomy"),
              dataTableOutput("taxonomy_data")
            )
          ),
          fluidRow(
            h3(uiOutput("tree_url"))
          )
        ),
        tabPanel(
          "How to use",
          includeMarkdown("assets/explorer_explanation.md")
        )
      )
    )
  )
)

# server ----

server <- function(input, output) {

  data_lists <- reactive({
    get_acc_info(
    species_select = input$combo$text,
    accessions_long = ftolr::accessions_long,
    accessions_wide = ftolr::accessions_wide,
    match_results_resolved_all = ftolr::ftol_match_results)
  })

  output$acc_data <- renderDataTable(
    data_lists()[["acc_data"]],
    options = data_table_settings,
    escape = FALSE
  )

  output$voucher_data <- renderDataTable(
    data_lists()[["voucher_data"]],
    options = data_table_settings,
    escape = FALSE
  )

  output$taxonomy_data <- renderDataTable(
    data_lists()[["taxonomy_data"]],
    options = data_table_settings,
    escape = FALSE
  )

  output$tree_url <- renderUI({
    a(
      "View species in tree",
      href = make_tree_search_url(
        base_url = base_url,
        species = input$combo$text
      )
    )
  })

}

shinyApp(ui = ui, server = server)