ui <- fluidPage(
  title="Add a new vessel visit",
  fluidRow(
    column(
      width = 6,
      selectInput(
        inputId='vessel_name',
        'Vessel Name:',
        choices=dbGetQuery(
          conn=conn,
          "SELECT VESSEL_NAME FROM VESSELS ORDER BY VESSEL_NAME"
        )$VESSEL_NAME
      ),
      selectInput(
        inputId='state',
        "State: ",
        choices=unique(
          dbGetQuery(
            conn=conn,
            "SELECT STATE_POSTAL FROM PORTS ORDER BY STATE_POSTAL"
          )$STATE_POSTAL
        )
      ),
      selectInput(
        inputId="port",
        label="Port: ",
        choices=dbGetQuery(
          conn=conn,
          paste0(
            "SELECT PORT_NAME FROM PORTS ORDER BY PORT_NAME"
          )
        )$PORT_NAME
      ),
      dateInput(
        inputId='vdate',
        label="Visit Date",
        format='yyyy-mm-dd'
      ),
      timeInput(
        inputId='vtime',
        label="Visit Time (local)",
        seconds=TRUE
      ),
      textAreaInput(
        inputId='notes',
        label="Visit Notes: ",
        value="",
        resize="both"
      ),
      actionButton(
        inputId="checkRecord",
        label="Check Record",
        icon('check')
      )
    )
  ),
  renderUI(
    textOutput('check')
  )
)