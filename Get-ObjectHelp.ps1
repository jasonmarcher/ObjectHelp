function Get-ObjectHelp {
    [CmdletBinding(DefaultParameterSetName = "Class")]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [PSObject]$Object
        ,
        [Parameter(ParameterSetName = "Class")]
        [switch]$Detailed
        ,
        [Parameter(ParameterSetName = "Method")]
        [string]$Method
        ,
        [Parameter(ParameterSetName = "Property")]
        [string]$Property
        ,
        [Parameter()]
        [switch]$Online
    )

    begin {
        $PSCmdlet.WriteVerbose("Begin")
    }

    process {
        $Type = $null
        $TypeName = $null
        $Selector = $null

        Write-Verbose "Start processing..."
        Write-Verbose ("Input object (Type:" + $Object.GetType() + ", IsType:" + ($Object -is [System.Type]) + ")")
        if ($Object -is [Management.Automation.PSMemberInfo]) {
            if ($Object -is [System.Management.Automation.PSMethod]) {
                $Method = $Object.Name
                $Type = Resolve-MemberOwnerType $Object
            } else {
                Write-Error "Unable to identify owning time of PSMembers."
                return
            }
        } elseif ($Object -is [Microsoft.PowerShell.Commands.MemberDefinition]) {
            if ($Object.MemberType -eq "Method") {
                $Method = $Object.Name
            } else {
                $Property = $Object.Name
            }
            if ($Object.TypeName -match '^System.Management.ManagementObject#(.+)') {
                $Type = $Object.TypeName
            } else {
                $Type = "$($Object.TypeName)" -as [System.Type]
            }
        } elseif ($Object -is [Microsoft.Management.Infrastructure.CimClass]) {
            $Type = $Object
        } elseif ($Object -is [Microsoft.Management.Infrastructure.CimInstance]) {
            $Type = $Object.PSBase.CimClass
        } elseif ($Object -is [System.Management.ManagementObject]) {
            $Type = Get-CimClass $Object.__CLASS -Namespace $Object.__NAMESPACE
        } elseif ($Object -is [System.__ComObject]) {
            $Type = $Object
        } elseif ($Object -is [System.String]) {
            switch -regex ($Object) {
                '^\[[^\[\]]+\]$' {
                    ## .NET Type (ex: [System.String])
                    try {
                        $Type = Invoke-Expression $Object
                    } catch {
                    }
                    break
                }
                '^Win32_[\w]+' {
                    $Type = Get-CimClass $Object
                }
                ## TODO: WMI / CIM
                Default {}
            }
        } elseif ($Object -as [System.Type]) {
            $Type = $Object -as [System.Type]
        }

        if (-not $Type) {
            Write-Error "Could not identify object"
            return
        }

        Write-Verbose ("Object (Type:" + $Object.GetType() + ", IsType:" + ($Object -is [System.Type]) + ")")
        Write-Verbose ("Method is: $Method")
        Write-Verbose ("Property is: $Property")

        $Culture = $Host.CurrentCulture.Name
        ## TODO: Support culture parameter?

        if ($Type -is [Microsoft.Management.Infrastructure.CimClass]) {
            if ($Online) {
                $TypeName = $Type.CimClassName
                if ($Method) {
                    $Suffix = "#methods"
                } elseif ($Property) {
                    $Suffix = "#properties"
                } else {
                    $Suffix = ""
                }
                $Uri = "http://msdn.microsoft.com/library/$Culture/wmisdk/wmi/$TypeName.asp$Suffix"
                [System.Diagnostics.Process]::Start($uri) > $null
            } else {
                if ($Method) {
                    Get-CimHelp -Class $Type.CimClassName -Namespace $Type.CimSystemProperties.Namespace -Method $Method
                } elseif ($Property) {
                    Get-CimHelp -Class $Type.CimClassName -Namespace $Type.CimSystemProperties.Namespace -Property $Property
                } else {
                    Get-CimHelp -Class $Type.CimClassName -Namespace $Type.CimSystemProperties.Namespace -Detailed:$Detailed
                }
            }
        } elseif ($Type -is [System.Type]) {
            if ($Online) {
                if ($Uri = Get-HelpUri $Type) {
                    [System.Diagnostics.Process]::Start($Uri.ToString()) > $null
                }
            } else {
                if ($Method) {
                    Get-NetHelp -Type $Type -Method $Method
                } elseif ($Property) {
                    Get-NetHelp -Type $Type -Property $Property
                } else {
                    Get-NetHelp -Type $Type -Detailed:$Detailed
                }
            }
        } elseif ($Type -is [System.__ComObject]) {
            if ($Online) {
                if ($Type.PSTypeNames[0] -match 'System\.__ComObject#(.*)$') {
                    if (Test-Path "HKLM:\SOFTWARE\Classes\Interface\$($Matches[1])") {
                        $TypeKey = (Get-ItemProperty "HKLM:\SOFTWARE\Classes\Interface\$($Matches[1])").'(default)'
                        if ('_Application' -contains $TypeKey) {
                            $TypeName = (Get-ItemProperty "HKLM:\SOFTWARE\Classes\TypeLib\$TypeLib\$Version").'(default)'
                        } else {
                            $TypeName = $TypeKey
                        }
                    }
                }
                $Uri = "http://social.msdn.microsoft.com/Search/$Culture/?query=$TypeName"
                [System.Diagnostics.Process]::Start($uri) > $null
            } else {
                Write-Error "Unable to find local help."
                return
            }
        }
    }
}

New-Alias -Name "ohelp" -Value "Get-ObjectHelp"