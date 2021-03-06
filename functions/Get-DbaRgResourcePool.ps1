﻿function Get-DbaRgResourcePool {
<#
.SYNOPSIS
Gets Resource Governor Pool objects, including internal or external

.DESCRIPTION
Gets Resource Governor Pool objects, including internal or external

.PARAMETER SqlInstance
The target SQL Server instance(s)

.PARAMETER SqlCredential
Allows you to login to SQL Server using alternative credentials

.PARAMETER InputObject
Allows input to be piped from Get-DbaResourceGovernor

.PARAMETER Type
Internal or External
    
.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.NOTES
Tags: ResourceGovernor
Website: https://dbatools.io
Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
License: MIT https://opensource.org/licenses/MIT

.LINK
https://dbatools.io/Get-DbaRgResourcePool

.EXAMPLE
Get-DbaRgResourcePool -SqlInstance sql2016

Gets the internal resource pools on sql2016

.EXAMPLE
'Sql1','Sql2/sqlexpress' | Get-DbaResourceGovernor | Get-DbaRgResourcePool

Gets the internal resource pools on Sql1 and Sql2/sqlexpress instances

.EXAMPLE
'Sql1','Sql2/sqlexpress' | Get-DbaResourceGovernor | Get-DbaRgResourcePool -Type External

Gets the external resource pools on Sql1 and Sql2/sqlexpress instances
    
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [ValidateSet("Internal", "External")]
        [string]$Type = "Internal",
        [parameter(ValueFromPipeline)]
        [Microsoft.SqlServer.Management.Smo.ResourceGovernor[]]$InputObject,
        [switch]$EnableException
    )
    
    process {
        foreach ($instance in $SqlInstance) {
            Write-Message -Level Verbose -Message "Connecting to $instance"
            $InputObject += Get-DbaResourceGovernor -SqlInstance $SqlInstance -SqlCredential $SqlCredential
        }
        
        foreach ($resourcegov in $InputObject) {
            if ($Type -eq "External") {
                $respool = $resourcegov.ExternalResourcePools
                if ($respool) {
                    $respool | Add-Member -Force -MemberType NoteProperty -Name ComputerName -value $resourcegov.ComputerName
                    $respool | Add-Member -Force -MemberType NoteProperty -Name InstanceName -value $resourcegov.InstanceName
                    $respool | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -value $resourcegov.SqlInstance
                    $respool | Select-DefaultView -Property ComputerName, InstanceName, SqlInstance, Id, Name, CapCpuPercentage, IsSystemObject, MaximumCpuPercentage, MaximumIopsPerVolume, MaximumMemoryPercentage, MinimumCpuPercentage, MinimumIopsPerVolume, MinimumMemoryPercentage, WorkloadGroups
                }
            }
            else {
                $respool = $resourcegov.ResourcePools
                if ($respool) {
                    $respool | Add-Member -Force -MemberType NoteProperty -Name ComputerName -value $resourcegov.ComputerName
                    $respool | Add-Member -Force -MemberType NoteProperty -Name InstanceName -value $resourcegov.InstanceName
                    $respool | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -value $resourcegov.SqlInstance
                    $respool | Select-DefaultView -Property ComputerName, InstanceName, SqlInstance, Id, Name, CapCpuPercentage, IsSystemObject, MaximumCpuPercentage, MaximumIopsPerVolume, MaximumMemoryPercentage, MinimumCpuPercentage, MinimumIopsPerVolume, MinimumMemoryPercentage, WorkloadGroups
                }
            }
        }
    }
}