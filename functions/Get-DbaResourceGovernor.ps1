﻿function Get-DbaResourceGovernor {
<#
.SYNOPSIS
Gets the Resource Governor object

.DESCRIPTION
Gets the Resource Governor object
    
.PARAMETER SqlInstance
The target SQL Server instance(s)

.PARAMETER SqlCredential
Allows you to login to SQL Server using alternative credentials

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
https://dbatools.io/Get-DbaResourceGovernor

.EXAMPLE
Get-DbaResourceGovernor -SqlInstance sql2016

Gets the resource governor object of the SqlInstance sql2016

.EXAMPLE
'Sql1','Sql2/sqlexpress' | Get-DbaResourceGovernor

Gets the resource governor object on Sql1 and Sql2/sqlexpress instances

#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [switch]$EnableException
    )
    
    process {
        foreach ($instance in $SqlInstance) {
            try {
                Write-Message -Level Verbose -Message "Connecting to $instance"
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $sqlcredential -MinimumVersion 10
            }
            catch {
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }
            
            $resourcegov = $server.ResourceGovernor
            
            if ($resourcegov) {
                Add-Member -Force -InputObject $resourcegov -MemberType NoteProperty -Name ComputerName -value $server.ComputerName
                Add-Member -Force -InputObject $resourcegov -MemberType NoteProperty -Name InstanceName -value $server.ServiceName
                Add-Member -Force -InputObject $resourcegov -MemberType NoteProperty -Name SqlInstance -value $server.DomainInstanceName
            }
            
            Select-DefaultView -InputObject $resourcegov -Property ComputerName, InstanceName, SqlInstance, ClassifierFunction, Enabled, MaxOutstandingIOPerVolume, ReconfigurePending, ResourcePools, ExternalResourcePools
        }
    }
}