param([string[]]$PreCacheList)

<#

.ForwardHelpTargetName Get-Help
.ForwardHelpCategory Cmdlet

#>

if ((!$SCRIPT:helpCache) -or $RefreshCache) {
    $SCRIPT:helpCache = @{}
}

foreach ($script in (Get-ChildItem $PSScriptRoot -Include *.ps1 -Recurse)) {
    . $script.FullName
}

function Get-HelpSummary
{
        [CmdletBinding()]
        param
        (        
            [string]$file,
            [reflection.assembly]$assembly,
            [string]$selector
        )
        
        if ($helpCache.ContainsKey($assembly))
        {            
            $xml = $helpCache[$assembly]
            
            $PSCmdlet.WriteVerbose("Docs were found in the cache.")
        }
        else
        {
            # cache it
            Write-Progress -id 1 "Caching Help Documentation" $assembly.getname().name

            # cache this for future lookups. It's a giant pig. Oink.
            $xml = [xml](gc $file)
            
            $helpCache.Add($assembly, $xml)
            
            Write-Progress -id 1 "Caching Help Documentation" $assembly.getname().name -completed
        }

        $PSCmdlet.WriteVerbose("Selector is $selector")        

        # TODO: support overloads
        $summary = $xml.doc.members.SelectSingleNode("member[@name='$selector' or starts-with(@name,'$selector(')]").summary
        
        $summary
}

# cache common assembly help
function PreloadDocumentation
{       
    if ($SCRIPT:helpCache.Keys.Count -eq 0) {
        # mscorlib
        $file = Get-HelpLocation ([int])
        Get-HelpSummary $file ([int].assembly) "T:System.Int32" > $null
        
        # system
        $file = Get-HelpLocation ([regex])    
        Get-HelpSummary $file ([regex].assembly) "T:System.Regex" > $null
    }
}

# our proxy command generated from [proxycommand]::create((gcm get-help))
# function Get-Help {
#     [CmdletBinding(DefaultParameterSetName='AllUsersView')]
#     param(
#         [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
#         [System.String]
#         ${Name},

#         [System.String]
#         ${Path},

#         [System.String[]]
#         ${Category},

#         [System.String[]]
#         ${Component},

#         [System.String[]]
#         ${Functionality},

#         [System.String[]]
#         ${Role},

#         [Parameter(ParameterSetName='DetailedView')]
#         [Switch]
#         ${Detailed},

#         [Parameter(ParameterSetName='AllUsersView')]
#         [Switch]
#         ${Full},

#         [Parameter(ParameterSetName='Examples')]
#         [Switch]
#         ${Examples},

#         [Parameter(ParameterSetName='Parameters')]
#         [System.String]
#         ${Parameter},
        
#         [Parameter(ParameterSetName='ObjectHelp', ValueFromPipeline = $true, Mandatory = $true)]
#         [ValidateNotNullOrEmpty()]
#         ${Object},

#         [Parameter(ParameterSetName='ObjectHelp')]
#         [String]
#         ${Member},
        
#         [Parameter(ParameterSetName='ObjectHelp')]
#         [Switch]
#         ${Static},        

#         [Switch]
#         ${Online})

#     begin
#     {
#         try {
#             if ($PSCmdlet.ParameterSetName -eq "ObjectHelp") {                                
                
#                 $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Get-ObjectHelp', [System.Management.Automation.CommandTypes]::Function)
#                 $scriptCmd = { & $wrappedCmd @PSBoundParameters }
#                 $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            
#             } else {
            
#                 $outBuffer = $null
#                 if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer) -and $outBuffer -gt 1024)
#                 {
#                     $PSBoundParameters['OutBuffer'] = 1024
#                 }
#                 $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Get-Help', [System.Management.Automation.CommandTypes]::Cmdlet)
#                 $scriptCmd = { & $wrappedCmd @PSBoundParameters }
#                 $steppablePipeline = $scriptCmd.GetSteppablePipeline()
                
#             }
#             $steppablePipeline.Begin($PSCmdlet)
#         } catch {
#             throw
#         }
#     }

#     process
#     {
#         try {        
#             $steppablePipeline.Process($_)
#         } catch {
#             throw
#         }
#     }

#     end
#     {
#         try {
#             $steppablePipeline.End()
#         } catch {
#             throw
#         }
#     }
# }

# PreloadDocumentation

# Export-ModuleMember Get-Help
Export-ModuleMember *-* -Alias *

@"
    NAME
    
        ObjectHelp Extensions Module 0.2 for PowerShell 2.0 CTP3
     
    SYNOPSIS
    
         Get-Help -Object allows you to display usage and summary help for .NET Types and Members.
         
    DETAILED DESCRIPTION
    
        Get-Help -Object allows you to display usage and summary help for .NET Types and Members.
    
        If local documentation is not found and the object vendor is Microsoft, you will be directed
        to MSDN online to the correct page. If the vendor is not Microsoft and vendor information
        exists on the owning assembly, you will be prompted to search for information using Microsoft
        Live Search.
     
    TODO
     
         * localize strings into PSD1 file
         * Implement caching in hashtables. XMLDocuments are fat pigs.
         * Support getting property/field help
         * PowerTab integration
         * Test with Strict Parser
             
    EXAMPLES

        # get help on a type
        PS> get-help -obj [int]

        # get help against live instances
        PS> $obj = new-object system.xml.xmldocument
        PS> get-help -obj `$obj

        or even:
        
        PS> get-help -obj 42
        
        # get help against methods
        PS> get-help -obj `$obj.Load

        # explictly try msdn
        PS> get-help -obj [regex] -online

        # go to msdn for regex's members
        PS> get-help -obj [regex] -online -members
        
        # pipe support
        PS> 1,[int],[string]::format | get-help -verbose
    
    CREDITS
    
        Author: Oisin Grehan (MVP)
        Blog  : http://www.nivot.org/
    
        Have fun!    
"@
