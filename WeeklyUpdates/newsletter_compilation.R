## Call the necessary packages
library(blastula)
## Prep the newsletter message from the markdown file
newsletter=blastula::render_email(
  input=file.choose()
)
## Test
blastula::smtp_send(
  email=newsletter,
  to="george.maynard@noaa.gov",
  from="snec.newsletter@gmail.com",
  subject="TEST Newsletter",
  credentials=creds_key(
    id='SNEC_MailR'
  )
)
# ## Production
# blastula::smtp_send(
#   email=newsletter,
#   to="eric.schultz@uconn.edu",
#   from="snec.newsletter@gmail.com",
#   subject="SNEC Newsletter",
#   credentials=creds_key(
#     id='SNEC_MailR'
#   )
# )
