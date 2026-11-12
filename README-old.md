# ftol_shiny

Home of code for shiny apps serving data related to the fern tree of life (FTOL).

For more information about FTOL, see https://fernphy.github.io.

## Running apps

Each app is contained in a subfolder.

To run, e.g. `ftol_explorer`, use `shiny::runApp("ftol_explorer")`.

## Deploying apps

Apps are deployed on [https://www.shinyapps.io/](https://www.shinyapps.io/).

To deploy, e.g. `ftol_explorer`, use `rsconnect::deployApp("ftol_explorer")` (requires setting up account on shinyapps.io and [authenticating](https://docs.rstudio.com/shinyapps.io/getting-started.html#configure-rsconnect)).

## License

Code: [MIT](LICENSE)