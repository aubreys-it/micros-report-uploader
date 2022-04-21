#########################################################################################
#   Aubrey's Micros Report Uploader
#   2022-04-20
#   Grant Houser
#
#   Uploads Daily, Monthly, and Payroll files and reports to Azure Data Lake
#   Workaround for PostecFileDistro sunset
#########################################################################################


#Set local path to Dropbox reports
$loc_path = "[PATH TO DROPBOX FILES]"
#Set restaurant department number
$location_id = "[LOCATION ID]"

#Data lake uri
$data_lake = "[DATA LAKE URI]"
$sas = "[DATA LAKE SAS"

#HTTP Headers
$headers = @{
        'x-ms-blob-type' = 'BlockBlob'
}


#Get all zip files modified in the last 7 days
$daily_folder = $loc_path + "Daily"
Set-Location -Path $daily_folder
foreach ($file in Get-ChildItem *.zip | Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-7)})
{
    $name = (Get-Item $file).Name
    $uri = $data_lake + "DAILY/$($name)" + $sas

    #Upload files to data lake
    Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file
}


#Get all zip files modified in the last 6 months
$monthly_folder = $loc_path + "Monthly"
Set-Location -Path $monthly_folder
foreach ($file in Get-ChildItem *.zip | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMonths(-6)})
{
    $name = (Get-Item $file).Name
    $uri = $data_lake + "MONTHLY/$($name)" + $sas

    #Upload files to data lake
    Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file
}

#Get all zip files modified in the last 3 months
$payroll_folder = $loc_path + "Payroll"
Set-Location -Path $payroll_folder
foreach ($file in Get-ChildItem *_payroll.zip | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMonths(-3)})
{
    $name = (Get-Item $file).Name
    $uri = $data_lake + "PAYROLL/$($name)" + $sas

    #Uplad files to data lake
    Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file
}

#Get the daily sales XLS file, rename it based on modified date and upload to cloud
$sales_file = $loc_path + "[SALES FILE SUB PATH]"
$upload_name = (Get-Item $sales_file).LastWriteTime.AddDays(-1).GetDateTimeFormats('d')[0] + "_$($location_id)_sales.xls"
$uri =  $data_lake + "MISALES/$($upload_name)" + $sas
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $sales_file

#Get the daily clock in/outs XLS file, rename it based on modified date and upload to cloud
$cio_file = $loc_path + "[CIO FILE SUB PATH]"
$upload_name = (Get-Item $cio_file).LastWriteTime.AddDays(-1).GetDateTimeFormats('d')[0] + "_$($location_id)_timecard.xls"
$uri =  $data_lake + "CIO/$($upload_name)" + $sas
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $cio_file

#Get the bi-weekly payroll CSV file, rename it based on modified date and upload to cloud
$payroll_csv = $loc_path + "[PAYROLLL FILE SUB PATH]"
$upload_name = (Get-Item $payroll_csv).LastWriteTime.AddDays(-1).GetDateTimeFormats('d')[0] + "_$($location_id)_payroll.csv"
$uri =  $data_lake + "PAYROLL/CSV/$($upload_name)" + $sas
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $payroll_csv
