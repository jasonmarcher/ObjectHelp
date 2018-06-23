function Get-WmiClassInfo {
    param(
        [Parameter(Position = 0)]
        [string]$Class
        ,
        [string]$Namespace = "ROOT\cimv2"
        ,
        [int]$CultureID = (Get-Culture).LCID
    )

    $LocalizedNamespace = Get-LocalizedNamespace $Namespace $CultureID
    $ClassLocation = $LocalizedNamespace + ':' + $Class

    $Options = New-Object System.Management.ObjectGetOptions
    $Options.UseAmendedQualifiers = $true

    ## Return
    New-Object System.Management.ManagementClass $ClassLocation,$Options
}