library(shiny)
library(RMySQL)
## Read in configuration values
db_config=config::get()$db

## Create database connection
conn=dbConnect(
  MySQL(), 
  user=db_config$username, 
  password=db_config$password, 
  dbname=db_config$dbname, 
  host=db_config$host,
  port=db_config$port
)

## Define the parts of the page
ui <- fluidPage(
    ## Application title
    titlePanel("Vessel Visit Log"),
    sidebarLayout(
      ## The Sidebar panel contains filters
      sidebarPanel(
        ## Select a vessel of interest
        selectInput(
          inputId='vessel',
          label="Vessel Name",
          choices=c(
            "ALL",
            unique(
            dbGetQuery(
              conn=conn,
              "SELECT VESSEL_NAME FROM VESSEL_VISIT_VIEW"
              )$VESSEL_NAME
            )[order(
            unique(
              dbGetQuery(
                conn=conn,
                "SELECT VESSEL_NAME FROM VESSEL_VISIT_VIEW"
              )$VESSEL_NAME
            )
          )]),
          selected="ALL",
          multiple=FALSE
        ),
        ## Select a technician of interest
        selectInput(
          inputId='tech',
          label="Technician Last Name",
          choices=c(
            "ALL",
            unique(
              dbGetQuery(
                conn=conn,
                "SELECT TECH_LAST FROM VESSEL_VISIT_VIEW"
              )$TECH_LAST
            )[order(
              unique(
                dbGetQuery(
                  conn=conn,
                  "SELECT TECH_LAST FROM VESSEL_VISIT_VIEW"
                )$TECH_LAST
              )
            )]),
          selected="ALL",
          multiple=FALSE
        ),
      position='left'
      ),
      ## The main panel contains the table of previous vessel visits
      mainPanel(
        tableOutput('vessel_visit_view')
      )
    )
)

# Define server logic
server <- function(input, output) {
  ## Create a function to view the visit log for a particular vessel
  vvv=reactive({
    if(input$vessel=="ALL"&&input$tech=="ALL"){
      dbGetQuery(
        conn=conn,
        "SELECT * FROM VESSEL_VISIT_VIEW ORDER BY VISIT_DATE DESC"
      )
    } else {
      if(input$vessel=="ALL"&&input$tech!="ALL"){
        dbGetQuery(
          conn=conn,
          paste0(
            "SELECT * FROM VESSEL_VISIT_VIEW WHERE TECH_LAST = '",
            input$tech,
            "' ORDER BY VISIT_DATE DESC"
          )
        )
      } else {
        if(input$vessel!="ALL"&&input$tech=="ALL"){
          dbGetQuery(
            conn=conn,
            paste0(
              "SELECT * FROM VESSEL_VISIT_VIEW WHERE VESSEL_NAME = '",
              input$vessel,
              "' ORDER BY VISIT_DATE DESC"
            )
          )
        } else {
          dbGetQuery(
            conn=conn,
            paste0(
              "SELECT * FROM VESSEL_VISIT_VIEW WHERE VESSEL_NAME = '",
              input$vessel,
              "' AND TECH_LAST = '",
              input$tech,
              "' ORDER BY VISIT_DATE DESC"
            )
          )
        }
      }
    }
  })
  output$vessel_visit_view=renderTable({
    vvv()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
