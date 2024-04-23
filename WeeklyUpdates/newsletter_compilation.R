## Call the necessary packages
library(blastula)
## Enter email credentials if you haven't already
# blastula::create_smtp_creds_key(
#   id="emolt_gmail",
#   user="emolt.erddap@gmail.com",
#   provider="gmail", overwrite=TRUE
# )
## Prep the newsletter message from the markdown file
newsletter=blastula::render_email(
  input=file.choose()
)
## Test
blastula::smtp_send(
  email=newsletter,
  to="george.maynard@noaa.gov",
  from="emolt.erddap@gmail.com",
  subject="eMOLT Newsletter",
  credentials=creds_key(
    id='emolt_gmail'
  )
)
