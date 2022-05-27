## UI logic
vesselIdInput <- function(id, label="Vessel ID"){
  ## Create a namespace function using the provided id
  ns=NS(id)
  ## Create a dropdown selector populated by vessel names in alphabetical order
  selectInput(
    inputId=ns("vessel_name"),
    label="Vessel Name",
    choices=dbGetQuery(
      conn=conn,
      statement="SELECT VESSEL_NAME FROM VESSELS ORDER BY VESSEL_NAME"
      )$VESSEL_NAME
    )
}

## Server logic
vesselId <- function(input, output, session){
  ## Convert the vessel name into an ID number
  vessel_id <- reactive({
    dbGetQuery(
      conn=conn,
      statement=paste0(
        "SELECT VESSEL_ID FROM VESSELS WHERE VESSEL_NAME = ",
        input$vessel_name
      )
    )
  })
  return(vessel_id)
}