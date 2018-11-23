@{
    ## Module Info
    ModuleVersion      = '0.3.0'
    Description        = "Extends Get-Help to display usage and summary help for COM, CIM (WMI) and .NET types."
    GUID               = '64a3d770-e369-4060-baac-6873bf74d1d7'
    # HelpInfoURI        = ''

    ## Module Components
    RootModule         = @("ObjectHelp.psm1")
    ScriptsToProcess   = @()
    TypesToProcess     = @()
    FormatsToProcess   = @("CimHelp/CimHelp.Format.ps1xml","DotNetHelp/NetHelp.Format.ps1xml")
    FileList           = @()

    ## Public Interface
    CmdletsToExport    = ''
    FunctionsToExport  = @("*")
    VariablesToExport  = @()
    AliasesToExport    = @("*")
    # DscResourcesToExport = @()
    # DefaultCommandPrefix = ''

    ## Requirements
    # CompatiblePSEditions = @()
    PowerShellVersion      = '3.0'
    # PowerShellHostName     = ''
    # PowerShellHostVersion  = ''
    RequiredModules        = @()
    RequiredAssemblies     = @()
    ProcessorArchitecture  = 'None'
    DotNetFrameworkVersion = '2.0'
    CLRVersion             = '2.0'

    ## Author
    Author             = 'Oisin Grehan'
    CompanyName        = ''
    Copyright          = ''

    ## Private Data
    PrivateData        = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @("help")

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @"
"@
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
