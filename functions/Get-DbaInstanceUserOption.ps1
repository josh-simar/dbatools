function Get-DbaInstanceUserOption {
    <#
        .SYNOPSIS
            Gets SQL Instance user options of one or more instance(s) of SQL Server.

        .DESCRIPTION
            The Get-DbaInstanceUserOption command gets SQL Instance user options from the SMO object sqlserver.

        .PARAMETER SqlInstance
            SQL Server name or SMO object representing the SQL Server to connect to.
            This can be a collection and receive pipeline input to allow the function to be executed against multiple SQL Server instances.

        .PARAMETER SqlCredential
            Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .NOTES
            Tags: Instance, Configure, UserOption
            Author: Klaas Vandenberghe (@powerdbaklaas)

            Website: https://dbatools.io
            Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
            License: MIT https://opensource.org/licenses/MIT

        .LINK
            https://dbatools.io/Get-DbaInstanceUserOption

        .EXAMPLE
            Get-DbaInstanceUserOption -SqlInstance localhost

            Returns SQL Instance user options on the local default SQL Server instance

        .EXAMPLE
            Get-DbaInstanceUserOption -SqlInstance sql2, sql4\sqlexpress

            Returns SQL Instance user options on default instance on sql2 and sqlexpress instance on sql4

        .EXAMPLE
            'sql2','sql4' | Get-DbaInstanceUserOption

            Returns SQL Instance user options on sql2 and sql4
    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $True)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [Alias('Silent')]
        [switch]$EnableException
    )

    process {
        foreach ($instance in $SqlInstance) {
            try {
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $sqlcredential
            }
            catch {
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }
            $props = $server.useroptions.properties
            foreach ($prop in $props) {
                Add-Member -Force -InputObject $prop -MemberType NoteProperty -Name ComputerName -Value $server.ComputerName
                Add-Member -Force -InputObject $prop -MemberType NoteProperty -Name InstanceName -Value $server.ServiceName
                Add-Member -Force -InputObject $prop -MemberType NoteProperty -Name SqlInstance -Value $server.DomainInstanceName
                Select-DefaultView -InputObject $prop -Property ComputerName, InstanceName, SqlInstance, Name, Value
            }
        }
    }
    end {
        Test-DbaDeprecation -DeprecatedOn "1.0.0" -EnableException:$false -Alias Get-DbaSqlInstanceUserOption
    }
}