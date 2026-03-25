# This app will be developed after the main data analysis and modelling pipeline is complete.

library(shiny)

ui <- fluidPage(
  titlePanel("Influenza Epidemic Modelling Dashboard"),
  mainPanel(p("Dashboard under development."), p("The current project stage focuses on data cleaning, exploratory analysis, and modelling."))
)

server <- function(input, output, session) {
}

shinyApp(ui = ui, server = server)