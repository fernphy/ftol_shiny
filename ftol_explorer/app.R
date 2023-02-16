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

}

shinyApp(ui = ui, server = server)