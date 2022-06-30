library(shiny)
library(shiny.react)
library(shiny.fluent)
library(tidyverse)

source("functions.R")

sanger_accessions_selection <- readRDS("data/sanger_accessions_selection.RDS")
ncbi_accepted_names_map <- readRDS("data/ncbi_accepted_names_map.RDS")
match_results_resolved_all <- readRDS("data/match_results_resolved_all.RDS")

species <- sort(sanger_accessions_selection$species)

options <- NULL
for (i in seq_along(species)) {
  options[[i]] <- list(key = species[[i]], text = species[[i]])
}

ui <- fluidPage(

  titlePanel("FTOL explorer"),

  sidebarLayout(

    sidebarPanel(
      # Use combo-box input for autocomplete
      ComboBox.shinyInput("combo", value = list(text = species[[1]]),
        options = options, allowFreeform = TRUE
      )
    ),

    mainPanel(
      dataTableOutput("view")
    )
  )

)

server <- function(input, output) {
  output$view <- renderDataTable({
    get_acc_info(
    input$combo$text,
    sanger_accessions_selection,
    ncbi_accepted_names_map,
    match_results_resolved_all)
  }, escape = FALSE
  )
}

shinyApp(ui = ui, server = server)