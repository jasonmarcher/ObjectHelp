function Search-WmiHelp(
        [ScriptBlock]$descriptionExpression={},

        [ScriptBlock]$methodExpression={}, 
        [ScriptBlock]$propertyExpression={},
	$namespaces="root\cimv2",
        $cultureID = (Get-Culture).LCID,
        [switch]$list
)
{    

    $resultWmiClasses = @{}
   
    foreach ($namespace in $namespaces)
    {
        #First, get a list of all localized namespaces under the current namespace
	
        $localizedNamespace = Get-LocalizedNamespace $namespace
        if ($localizedNamespace -eq $null)
        {
    	    Write-Verbose "Could not get a list of localized namespaces"
            return
	}

        $localizedClasses = Get-WmiObject -NameSpace $localizedNamespace -Query "select * from meta_class"
        $count = 0;
        foreach ($WmiClass in $localizedClasses)
        {
            $count++
            Write-Progress "Searching Wmi Classes" "$count of $($localizedClasses.Count)" -Perc ($count*100/$localizedClasses.Count)
            $classLocation= $localizedNamespace + ':' + $WmiClass.__Class
            $classInfo = Get-WmiClassInfo $classLocation
            [bool]$found = $false
            if ($classInfo -ne $null)
            {
                if (! $resultWmiClasses.ContainsKey($classLocation))
                {
                    $resultWmiClasses.Add($wmiClass.__Class, $classInfo)
                }

                $descriptionMatch = [bool]($classInfo.Description | where $descriptionExpression)
                $methodMatch = [bool]($classInfo.Methods.GetEnumerator() | where $methodExpression)
                $propertyMatch = [bool]($classInfo.Properties.GetEnumerator() | where $propertyExpression)

                $found = $descriptionMatch -or $methodMatch -or $propertyMatch
                
                if (! $found)
                {
                    $resultWmiClasses.Remove($WmiClass.__Class)
                }
            }
      	}      	    
    }

    if ($list)
    {
        $resultWmiClasses.Keys | sort
    } else {
        $resultWmiClasses.GetEnumerator() | sort Key
    }
}