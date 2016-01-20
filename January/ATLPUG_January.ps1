<#
.Synopsis
   From a server or a list of serves, get the current uptime.
.DESCRIPTION
   Connects to a server or a list of servers one at a time and gets the current uptime.  It also checks to see if the server needs patching or reboot.
.EXAMPLE
   Get-Uptime -Computername test1.dom.com -Patching -Reboot
.EXAMPLE
   "Server1", "Server2", "Server3" | Get-Uptime -Patching -Reboot
#>
function Get-Uptime {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Computername = 'localhost'
     )
 
    Begin{
    }
    Process{
        foreach($Computer in $Computername){
            if (Test-Connection -ComputerName $Computer -Quiet -Count 1){
            #computer is online, run queries
            try {
                $OSInfo = Get-CimInstance Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
                $UpTimeDays = [math]::Round(($OSInfo.LocalDateTime - $OSInfo.LastBootUpTime  | Select -expand TotalDays),1)
                $startTime = $OSInfo.LastBootUpTime
                $status = "OK"
                
                if ($UpTimeDays -ge 30){
                    $mightNeedPatched=$true
                    }
                    else{
                    $mightNeedPatched=$false
                    }
                    
                }
            catch{
                $startTime = $null
                $UpTimeDays = $null
                $status = "ERROR"
            
            }
                
            }
            ELSE{
            #if computer is not online, print a dummy object
                Write-Warning "$Computer is offline"
                $startTime = $null
                $UpTimeDays = $null
                $status = "OFFLINE"
            
            }

            [pscustomobject]@{
                   ComputerName=$computer
                      StartTime=$startTime
                "Uptime (Days)"=$UpTimeDays
                         Status=$status
               MightNeedPatched=$false}
        }#end of for each
    }#end of process
    End{
    }
}#end of function
 
 