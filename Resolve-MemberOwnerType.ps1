function Resolve-MemberOwnerType {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [System.Management.Automation.PSMethod]$Method
    )

    # TODO: support overloads, support interface definitions

    $PSCmdlet.WriteVerbose("Resolving owning type of '$($Method.Name)'.")

    # hackety-hack - this is prone to breaking in the future
    $TargetType = [System.Management.Automation.PSMethod].GetField("baseObject", "Instance,NonPublic").GetValue($Method)
    if (($TargetType -isnot [System.Type]) -and (-not $TargetType.__CLASS)) {
        $TargetType = $TargetType.GetType()
    }

    if ($TargetType -is [System.Management.ManagementObject]) {
        $DeclaringType = Get-CimClass $TargetType.__CLASS -Namespace $TargetType.__NAMESPACE
    } else {
        if ($Method.OverloadDefinitions -match "static") {
            $Flags = "Static,Public"
        } else {
            $Flags = "Instance,Public"
        }

        # FIXME: support overloads
        $MethodInfo = $TargetType.GetMethods($Flags) | Where-Object {$_.Name -eq $Method.Name} | Select-Object -First 1

        if (-not $MethodInfo) {
            # this shouldn't happen.
            throw "Could not resolve owning type."
        }

        $DeclaringType = $MethodInfo.DeclaringType
    }
    
    $PSCmdlet.WriteVerbose("Owning type is $($TargetType.FullName). Method declared on $($DeclaringType.FullName).")
    $DeclaringType
}