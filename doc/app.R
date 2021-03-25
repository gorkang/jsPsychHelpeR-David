library(shiny)
suppressPackageStartupMessages(library(tidyverse))
DF_analysis = read_csv(here::here("output/data/DF_analysis.csv"),
              col_types =
                cols(
                  .default = col_double(),
                  id = col_integer(),
                  AIM_DIRt = col_character()
                ))

# targets::tar_load(DF_analysis)

names_variables = names(DF_analysis)


# Define UI for random distribution app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel(""),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(width = 2,
      
      selectInput(inputId = "variable", 
                  label = "Name variable:",
                  choices = names_variables, multiple = TRUE,
                  size = 20, 
                  selectize = FALSE,
                  selected = names_variables[1]),
      
      textInput(inputId = "bins", label = "Bins histogram", value = "30"),
      
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(width = 10,
      
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", plotOutput("plot")),
                  tabPanel("Summary", dataTableOutput("summary")),
                  tabPanel("Table", dataTableOutput("table"))
      )
      
    )
  )
)

server <- function(input, output) {
  
  d <- reactive({
    DF_analysis %>% select(id, input$variable)
  })
  
  output$plot <- renderPlot({
    d() %>% 
      ggplot(aes_string(input$variable)) + 
      geom_histogram(bins = input$bins) +
      theme_minimal()
  })
  
  # Generate a summary of the data ----
  # output$summary <- renderPrint({
  #   summary(d())
  # })
  output$summary <- renderDataTable({
    skimr::skim(d() %>% select(-id))
  })
  
  # Generate an HTML table view of the data ----
  output$table <- renderDataTable({
    d()
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)
