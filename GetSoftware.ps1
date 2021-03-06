$servers = @()
$servers = Get-QADComputer -SizeLimit 0 -OSName 'Windows Server*' | where {($_.Name -like "AL*")} | sort name

FOREACH ($server in $servers) 
	{
	$report=@()
	$row=@()	
	#$row = "" | Select-Object Software
	$computername=$server.dNSHostName
	$servershort = $server.Name
	$Branch='LocalMachine'  
	$SubBranch="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"  
	$continue = $true
			try
			{
			$registry=[microsoft.win32.registrykey]::OpenRemoteBaseKey('Localmachine',$computername)  
			$registrykey=$registry.OpenSubKey($Subbranch)  
			$SubKeys=$registrykey.GetSubKeyNames()  
			 
				Foreach ($key in $subkeys)  
					{  
				    $exactkey=$key  
				    $NewSubKey=$SubBranch+"\\"+$exactkey  
				    $ReadUninstall=$registry.OpenSubKey($NewSubKey)  
				    $Value=$ReadUninstall.GetValue("DisplayName") 
				#	Write-Host $value
			  		$row += $Value 
					}  
			$Branch='LocalMachine'  
			$SubBranch="SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"  
			 
			$registry=[microsoft.win32.registrykey]::OpenRemoteBaseKey('Localmachine',$computername)  
			$registrykey=$registry.OpenSubKey($Subbranch)  
			$SubKeys=$registrykey.GetSubKeyNames()  

					Foreach ($key in $subkeys)  
					{  
					    $exactkey=$key  
					    $NewSubKey=$SubBranch+"\\"+$exactkey  
					    $ReadUninstall=$registry.OpenSubKey($NewSubKey)  
					    $Value=$ReadUninstall.GetValue("DisplayName")  
					    $row += $Value
					}
			}
			catch
			{
			$continue = $false
			}
				if ($continue)
					{
					$sort = $row | sort
					$sort | Out-File "c:\Users\stiles.john\Desktop\Tools\Server Info\Software\$servershort.csv"
					}
				else
					{
					$servershort | out-file "c:\Users\stiles.john\Desktop\Tools\Server Info\Software\$servershort IS NOT ACCESSIBLE"
					}
	}