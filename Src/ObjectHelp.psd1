@{
    ## Module Info
    ModuleVersion      = '0.4.0'
    Description        = 'Provides help in the console for COM, CIM (WMI) and .NET types.'
    GUID               = '64a3d770-e369-4060-baac-6873bf74d1d7'
    # HelpInfoURI        = ''

    ## Module Components
    RootModule         = @('ObjectHelp.psm1')
    ScriptsToProcess   = @()
    TypesToProcess     = @()
    FormatsToProcess   = @('CimHelp.Format.ps1xml','NetHelp.Format.ps1xml')
    FileList           = @()

    ## Public Interface
    CmdletsToExport    = ''
    FunctionsToExport  = @('Get-ObjectHelp','Get-NetHelp','Get-CimHelp')
    VariablesToExport  = @()
    AliasesToExport    = @('ohelp')
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
    Author             = 'Oisin Grehan, Jason Archer'
    CompanyName        = ''
    Copyright          = ''

    ## Private Data
    PrivateData        = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('help','msdn')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @"
## 2018-12-01 - Version 0.4.0

Features:

- Console formatted help for .NET and CIM objects
- Links to online help for Microsoft .NET and CIM objects
"@
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
