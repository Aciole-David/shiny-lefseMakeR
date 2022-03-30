#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("LEfSeMakeR: build LEfSe input files!"),
    print("Upload your otu-table:"),
    fileInput("upload", NULL, accept = ".txt"),
    numericInput("n", "Rows to skip", value = 1, min = 0),
    tableOutput("head")
)

server <- function(input, output, session) {
    data <- reactive({
        req(input$upload)
        
        ext <- tools::file_ext(input$upload$name)
        switch(ext,
               txt = vroom::vroom(input$upload$datapath, delim = "\t"),
               validate("Invalid file; Please upload a .csv or .tsv file")
        )
    })
    
    output$head <- renderTable({
        head(data(), 5)
    })

}

# Run the application 
shinyApp(ui <- ui, server <- server)
