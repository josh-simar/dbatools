﻿function Get-DbaPbmCategorySubscription {
    <#
    .SYNOPSIS
    Returns policy category subscriptions from policy based management from an instance.

    .DESCRIPTION
    Returns policy category subscriptions from policy based management from an instance.
    
    .PARAMETER SqlInstance
    SQL Server name or SMO object representing the SQL Server to connect to. This can be a collection and receive pipeline input to allow the function to be executed against multiple SQL Server instances.

    .PARAMETER SqlCredential
    Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER InputObject
    Allows piping from Get-DbaPbmStore
    
    .PARAMETER EnableException
    By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
    This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
    Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
    Tags: Policy, PoilcyBasedManagement, PBM

    Website: https://dbatools.io
    Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
    License: MIT https://opensource.org/licenses/MIT

    .LINK
    https://dbatools.io/Get-DbaPbmCategorySubscription

    .EXAMPLE
    Get-DbaPbmCategorySubscription -SqlInstance sql2016

    Returns all policy category subscriptions from the sql2016 PBM server

    .EXAMPLE
    Get-DbaPbmCategorySubscription -SqlInstance sql2016 -SqlCredential $cred

    Uses a credential $cred to connect and return all policy category subscriptions from the sql2016 PBM server
#>
    [CmdletBinding()]
    param (
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [Parameter(ValueFromPipeline)]
        [Microsoft.SqlServer.Management.Dmf.PolicyStore[]]$InputObject,
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            $InputObject += Get-DbaPbmStore -SqlInstance $instance -SqlCredential $SqlCredential
        }
        foreach ($store in $InputObject) {
            $all = $store.PolicycategorySubscriptions
            
            foreach ($current in $all) {
                Write-Message -Level Verbose -Message "Processing $current"
                Add-Member -Force -InputObject $current -MemberType NoteProperty ComputerName -value $store.ComputerName
                Add-Member -Force -InputObject $current -MemberType NoteProperty InstanceName -value $store.InstanceName
                Add-Member -Force -InputObject $current -MemberType NoteProperty SqlInstance -value $store.SqlInstance
                Select-DefaultView -InputObject $current -ExcludeProperty Properties, Urn, Parent
            }
        }
    }
}