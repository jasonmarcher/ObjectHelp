function Get-LocalizedNamespace {
    param(
        $NameSpace
        ,
        [int]$cultureID = (Get-Culture).LCID
    )

    #First, get a list of all localized namespaces under the current namespace
    $localizedNamespaces = Get-WmiObject -NameSpace $NameSpace -Class "__Namespace" | where {$_.Name -like "ms_*"}
    if ($localizedNamespaces -eq $null)
    {
        if (-not $quiet)
        {
            Write-Warning "Could not get a  list of localized namespaces"
        }
        return
    }

    return ("$namespace\ms_{0:x}" -f $cultureID)
}