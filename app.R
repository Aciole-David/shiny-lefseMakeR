#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboardPlus)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("LEfSeMakeR: easily build LEfSe input files"),
    
    sidebarLayout(
      sidebarPanel(width = 3,
    print("Upload your map:"),
    fileInput("metadata", NULL),
    print("Upload your otu-table:"),
    fileInput("otu_table", NULL),
    downloadButton("downloadData", "Download your LEfSe file")
      ),

    mainPanel(
    h3("Check map file:"),
    tableOutput(outputId = "map.output"),
    h3("Check otu file:"),
    tableOutput(outputId = "otu.output"),
    h3("Check the formatted lefse input:"),
    tableOutput(outputId = "lefse.output")
    )
  )
)
server <- function(input, output, session) {
    # M A P
    mymap <- reactive({
    mapfile <- input$metadata
     if (is.null(mapfile))
      return(NULL)
    showModal(modalDialog("Loading map...", footer=NULL))#waiting message
    Sys.sleep(1)
    maptbl <- read.delim2(mapfile$datapath)
    removeModal()
     return(maptbl)
    

})
    # O T U 
    myotu <- reactive({
    otufile <- input$otu_table
     if (is.null(otufile))
      return(NULL)
    showModal(modalDialog("Loading otu-table...", footer=NULL))
    Sys.sleep(2)
    otutbl <- read.delim2(otufile$datapath, check.names = F, header = F)
    removeModal()
    Sys.sleep(1)
     return(otutbl)
    
    
})
    # L E F S E 
    mylefse <- reactive({
    map=input$metadata
    if (is.null(map))
      return(NULL)
    
    otu=input$otu_table
    if (is.null(otu))
      return(NULL)
    
    mm=read.delim2(file = map$datapath, check.names = F)
    
    raw=read.delim2(file = otu$datapath, check.names = F, header = F)
    
    
    if (grepl("Constructed from biom file", raw[1,1])) {
      oth=raw[-1,]
      oth=oth[1,]
      otb=raw[-(1:2),]
      
    } else {
      oth=raw
      oth=oth[1,]
      otb=raw[-1,]
      }
    
    oth[1,1]="Samples"


    oth=oth[,-ncol(oth)]
    oth=rbind(NA, oth)

    oth[1,]=data.table::transpose(mm[match(x=oth[2,], table = mm[,1]),])[2,]

    oth[1,1]="Class"


    otb[,1]=otb[ , ncol(otb)]
    otb=otb[,-ncol(otb)]
    otb=data.frame(lapply(otb, function(x) {
      gsub("; ", "|", x)
      }))
    
    final=rbind(oth,otb)
    #finaltable=write.table(x = final, file = "lefse-input.tabular", sep = "\t", col.names = F, row.names = F)
    if (is.null(final))
       return(NULL)
    showModal(modalDialog("Building LEfSe input...", footer=NULL))
    Sys.sleep(2)
    removeModal()
      return(final)
    
})

 output$map.output <- renderTable({
    head(mymap(),5)
 })
 
output$otu.output <- renderTable({
    head(myotu(),5)
 }) 
        
output$lefse.output <- renderTable({
    head(mylefse(),5)
 }) 

# Downloadable table 
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(gsub(pattern = ".txt",x = input$otu_table, replacement = ""),
            "-lefse.tabular", sep = "")
    },
    content = function(file) {
      showModal(modalDialog("Downloading your file...", footer=NULL))
      write.csv(write.table(x = mylefse(), file = file, sep = "\t", col.names = F, row.names = F))
      Sys.sleep(2)
      removeModal()
    }
  )
  
}

# Run the application 
shinyApp(ui <- ui, server <- server)
