mylines = [] #Declare empty list named mylines
with open ("/home/emolt/reboot_info.log","rt") as myfile: #Open the logfile and read it in
    for myline in myfile: #For each line in the file
        mylines.append(myline) #Append it to the list
timestamp=mylines[0] #The first value is the timestamp
mac=mylines[1] #The second value is the MAC address
ip=mylines[2] #The third value is the IP address
ll=len(mylines) #If there's a fourth value, it's the IP address of the VPN tunnel
if ll > 3:
    vpn=mylines[3]
else: #If there is no fourth value, insert a dummy value as a placeholder
    vpn="999"
timestamp=timestamp.replace(":","%3A") ## Replace ":" with "%3A" for proper interpretation by the API
mac=mac.replace(":","%3A")
timestamp=timestamp[:-4] ## Remove the timezone character string
timestamp=timestamp.split(" ") ## Split timestamp into date (ymd) and time (hms) values
ymd=timestamp[0]
hms=timestamp[1]
#if hms.startswith('0'): ## If it exists, replace the leading 0 in the hms value with "%200"
#    hms=hms[1:len(hms)]
#    hms="%200"+hms 
#else:
#    hms="%20"+hms
hms="%20"+hms
url='http://73.114.111.175:6666/insert_reboot?timestamp='+ymd+hms+'&MAC='+mac+'&IP='+ip
url= "".join([line.strip() for line in url]) ## Concatenate text and remove line breaks to create the url that will be used to pass information to the API
cmd='curl -X POST "'+url+'" -H "accept: */*" -d ""'
#cmd='curl -X POST "'+url+'" -H "accept: */*"'
file=open("/home/emolt/insert_reboot.sh","w") ## Create a file to store the new curl command
L = ["#!/bin/bash \n",cmd] 
file.writelines(L) ## Write the command to the file
file.close() ## Close the file
