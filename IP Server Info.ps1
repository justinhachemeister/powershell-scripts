$iprange = Get-IPrange -start 10.33.20.1 -end 10.33.20.254

$list=@()
foreach ($ip in $iprange) {
    $ok = Test-Connection $ip -Count 1 -Quiet 
    if ($ok) {
        $hostn = [System.Net.Dns]::GetHostEntry($ip).HostName
        #New-Object -TypeName PSObject -Property @{'Host'=$hostn;'IP'=$ip}
		$list += $hostn
        }
    }
	

#$global:compname=@()

#$global:compname = Get-QADComputer -SizeLimit 0 -OSName 'Windows Server*' | where {$_.Name -like "AL1*"} | sort name
$report=@()
foreach ($name in $list)
	{
	$server = $name
	$continue = $true
	$row = "" | Select-Object Name,Manufacturer,Model,AssetTag,Serial,OS,CPU,"Number of CPUs","CPU Load",Memory,MemoryFree,IP,SubnetMask,DefaultGateway,Domain
            try 
				{
    	        $serial = Get-WmiObject -ComputerName $server -Class Win32_SystemEnclosure –erroraction Stop
 	            }
				catch
				{
 	         	   	$continue = $false
               		$row.Name = $server + " is not accessible"
					$report += $row
 		        }
             if ($continue) 
				{
				$SystemInfo = Get-WmiObject -ComputerName $server -Class Win32_ComputerSystem
				$OSInfo = Get-WmiObject -ComputerName $server -Class Win32_OperatingSystem
			#	$OSInfo1 = Get-WmiObject -ComputerName $name -Class Win32_OperatingSystem
				$Proc = Get-WmiObject -ComputerName $server -Class "win32_processor" | select -First 1
				$CPULoad = $Proc | Measure-Object -Property LoadPercentage -Average | select Average
				$Net = get-wmiobject -computername $server -Class Win32_NetworkAdapterConfiguration | where {$_.Ipaddress.length -gt 0}
#						$row = "" | Select-Object Name,Manufacturer,Model,AssetTag,Serial,OS,CPU,"Number of CPUs","CPU Load",Memory,MemoryFree,IP,SubnetMask,DefaultGateway,Domain
						$row.Name = $SystemInfo.Name
			#			$row.Role = $OSInfo.Description
						$row.Manufacturer = $SystemInfo.Manufacturer
						$row.Model = $SystemInfo.Model
						$row.AssetTag = $serial.SMBIOSAssetTag
						$row.Serial = $serial.serialnumber
						$row.OS = $OSInfo.Caption + " " + $OSInfo.CSDVersion
						$row.CPU = $Proc.Name
						$row."Number of CPUs" = $SystemInfo.NumberOfProcessors
						$row."CPU Load" = ([string]$CPULoad.Average) + "%"
						$row.Memory = "{0:N2}" -f ($OSInfo.TotalVisibleMemorySize / 1MB)+" GB"
						$row.MemoryFree = "{0:N2}" -f ($OSinfo.FreePhysicalMemory / 1MB)+" GB"
						$row.IP = $Net.IPAddress | select -First 1
						$row.SubnetMask = $Net.IPSubnet | select -First 1
						$row.DefaultGateway = $Net.DefaultIPGateway | select -First 1
			#			$row.WINS = $Net.WINSPrimaryServer
			#			$row.DNS = $Net.DNSServerSearchOrder
			#				foreach ($dns in $Net.DNSServerSearchOrder)
			#				{
			#				$row.DNS += $dns
			#				}
			#			$row.DNSSuffix = $Net.DNSDomainSuffixSearchOrder
						$row.Domain = $SystemInfo.Domain
						
						$report += $row
			}
	}
#$report | Export-Csv 'c:\Users\stiles.john\Desktop\Tools\Server Info\Endo Serverinfo.csv' -NoTypeInformation

#$serverMem = (Get-WmiObject -Class CIM_PhysicalMemory -ComputerName $Name | Measure-Object -Property Capacity -Sum)
#"{0:N0}" -f ($servermem.sum / 1GB) + " GB Total Memory"
