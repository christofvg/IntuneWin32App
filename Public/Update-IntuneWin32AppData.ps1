function Update-IntuneWin32AppData {
    <#
    .SYNOPSIS
        Create a new Win32 application in Microsoft Intune.

    .DESCRIPTION
        Create a new Win32 application in Microsoft Intune.

    .PARAMETER ApplicationId
        Specify the win 32 application ID to update.

    .PARAMETER FilePath
        Specify a local path to where the win32 app .intunewin file is located.

    .PARAMETER DisplayName
        Specify a display name for the Win32 application.
    
    .PARAMETER Description
        Specify a description for the Win32 application.
    
    .PARAMETER Publisher
        Specify a publisher name for the Win32 application.
    
    .PARAMETER Developer
        Specify the developer name for the Win32 application.

    .PARAMETER Owner
        Specify the owner property for the Win32 application.

    .PARAMETER Notes
        Specify the notes property for the Win32 application.

    .PARAMETER InformationURL
        Specify the information URL for the Win32 application.
    
    .PARAMETER PrivacyURL
        Specify the privacy URL for the Win32 application.
    
    .PARAMETER CompanyPortalFeaturedApp
        Specify whether to have the Win32 application featured in Company Portal or not.

    .PARAMETER InstallCommandLine
        Specify the install command line for the Win32 application.
    
    .PARAMETER UninstallCommandLine
        Specify the uninstall command line for the Win32 application.

    .PARAMETER InstallExperience
        Specify the install experience for the Win32 application. Supported values are: system or user.
    
    .PARAMETER RestartBehavior
        Specify the restart behavior for the Win32 application. Supported values are: allow, basedOnReturnCode, suppress or force.
    
    .PARAMETER DetectionRule
        Provide an array of a single or multiple OrderedDictionary objects as detection rules that will be used for the Win32 application.

    .PARAMETER RequirementRule
        Provide an OrderedDictionary object as requirement rule that will be used for the Win32 application.

    .PARAMETER AdditionalRequirementRule
        Provide an array of OrderedDictionary objects as additional requirement rule, e.g. for file, registry or script rules, that will be used for the Win32 application.

    .PARAMETER ReturnCode
        Provide an array of a single or multiple hash-tables for the Win32 application with return code information.

    .PARAMETER Icon
        Provide a Base64 encoded string of the PNG/JPG/JPEG file.

    .NOTES
        Author:      Nickolaj Andersen
        Contact:     @NickolajA
        Created:     2020-01-04
        Updated:     2020-09-20

        Version history:
        1.0.0 - (2020-01-04) Function created
        1.0.1 - (2020-01-27) Added support for RequirementRule parameter input
        1.0.2 - (2020-09-20) Added support for Owner, Notes, InformationURL, PrivacyURL and CompanyPortalFeaturedApp parameter inputs
    #>
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName = "MSI")]
    param(
        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify the win 32 application ID to update.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationId,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify a local path to where the win32 app .intunewin file is located.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^[A-Za-z]{1}:\\\w+")]
        [ValidateScript({
            # Check if path contains any invalid characters
            if ((Split-Path -Path $_ -Leaf).IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) {
                Write-Warning -Message "$(Split-Path -Path $_ -Leaf) contains invalid characters"; break
            }
            else {
            # Check if file extension is intunewin
                if ([System.IO.Path]::GetExtension((Split-Path -Path $_ -Leaf)) -like ".intunewin") {
                    return $true
                }
                else {
                    Write-Warning -Message "$(Split-Path -Path $_ -Leaf) contains unsupported file extension. Supported extension is '.intunewin'"; break
                }
            }
        })]
        [string]$FilePath,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify a display name for the Win32 application.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify a description for the Win32 application.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify a publisher name for the Win32 application.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [string]$Publisher,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Specify the developer name for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [string]$Developer = [string]::Empty,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Specify the owner property for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [string]$Owner = [string]::Empty,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Specify the notes property for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [string]$Notes = [string]::Empty,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Specify the information URL for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidatePattern("(http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+)")]
        [string]$InformationURL = [string]::Empty,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Specify the privacy URL for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidatePattern("(http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+)")]
        [string]$PrivacyURL = [string]::Empty,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Specify whether to have the Win32 application featured in Company Portal or not.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [bool]$CompanyPortalFeaturedApp = $false,

        [parameter(Mandatory = $true, ParameterSetName = "EXE", HelpMessage = "Specify the install command line for the Win32 application.")]
        [ValidateNotNullOrEmpty()]
        [string]$InstallCommandLine,

        [parameter(Mandatory = $true, ParameterSetName = "EXE", HelpMessage = "Specify the uninstall command line for the Win32 application.")]
        [ValidateNotNullOrEmpty()]
        [string]$UninstallCommandLine,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify the install experience for the Win32 application. Supported values are: system or user.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("system", "user")]
        [string]$InstallExperience,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Specify the restart behavior for the Win32 application. Supported values are: allow, basedOnReturnCode, suppress or force.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("allow", "basedOnReturnCode", "suppress", "force")]
        [string]$RestartBehavior,

        [parameter(Mandatory = $true, ParameterSetName = "MSI", HelpMessage = "Provide an array of a single or multiple OrderedDictionary objects as detection rules that will be used for the Win32 application.")]
        [parameter(Mandatory = $true, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Specialized.OrderedDictionary[]]$DetectionRule,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Provide an OrderedDictionary object as requirement rule that will be used for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Specialized.OrderedDictionary]$RequirementRule,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Provide an array of OrderedDictionary objects as additional requirement rule, e.g. for file, registry or script rules, that will be used for the Win32 application.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Specialized.OrderedDictionary[]]$AdditionalRequirementRule,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Provide an array of a single or multiple hash-tables for the Win32 application with return code information.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable[]]$ReturnCode,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "Provide a Base64 encoded string of the PNG/JPG/JPEG file.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [string]$Icon,

        [parameter(Mandatory = $false, ParameterSetName = "MSI", HelpMessage = "The version displayed in the UX for this app.")]
        [parameter(Mandatory = $false, ParameterSetName = "EXE")]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayVersion
    )
    Begin {
        # Ensure required auth token exists
        if ($Global:AuthToken -eq $null) {
            Write-Warning -Message "Authentication token was not found, use Connect-MSIntuneGraph before using this function"; break
        }
        else {
            $AuthTokenLifeTime = ($Global:AuthToken.ExpiresOn.datetime - (Get-Date).ToUniversalTime()).Minutes
            if ($AuthTokenLifeTime -le 0) {
                Write-Verbose -Message "Existing token found but has expired, use Connect-MSIntuneGraph to request a new authentication token"; break
            }
            else {
                Write-Verbose -Message "Current authentication token expires in (minutes): $($AuthTokenLifeTime)"
            }
        }

        # Set script variable for error action preference
        $ErrorActionPreference = "Stop"

        # Validate that DetectionRule parameter input doesn't consist of a mix of Script and other detection rule types
        ####
    }
    Process {
        try {

            # Generate Win32 application body data table with different parameters based upon parameter set name
            Write-Verbose -Message "Start constructing basic layout of Win32 app body"
            switch ($PSCmdlet.ParameterSetName) {
                "MSI" {
                    # Determine the execution context of the MSI installer and define the installation purpose
                    $MSIExecutionContext = $IntuneWinXMLMetaData.ApplicationInfo.MsiInfo.MsiExecutionContext
                    $MSIInstallPurpose = "DualPurpose"
                    switch ($MSIExecutionContext) {
                        "System" {
                            $MSIInstallPurpose = "PerMachine"
                        }
                        "User" {
                            $MSIInstallPurpose = "PerUser"
                        }
                    }

                    # Handle special meta data variable values
                    $MSIRequiresReboot = $IntuneWinXMLMetaData.ApplicationInfo.MsiInfo.MsiRequiresReboot
                    switch ($MSIRequiresReboot) {
                        "true" {
                            $MSIRequiresReboot = $true
                        }
                        "false" {
                            $MSIRequiresReboot = $false
                        }
                    }

                    # Handle special parameter inputs
                    if (-not($PSBoundParameters["DisplayName"])) {
                        $DisplayName = $IntuneWinXMLMetaData.ApplicationInfo.Name
                    }
                    if (-not($PSBoundParameters["Description"])) {
                        $Description = $IntuneWinXMLMetaData.ApplicationInfo.Name
                    }
                    if (-not($PSBoundParameters["Publisher"])) {
                        $Publisher = $IntuneWinXMLMetaData.ApplicationInfo.MsiInfo.MsiPublisher
                    }
                    if (-not($PSBoundParameters["Developer"])) {
                        $Developer = [string]::Empty
                    }
                    
                    # Generate Win32 application body
                    $AppBodySplat = @{
                        "MSI" = $true
                        "DisplayName" = $DisplayName
                        "Description" = $Description
                        "Publisher" = $Publisher
                        "Developer" = $Developer
                        "Owner" = $Owner
                        "Notes" = $Notes
                        "InformationURL" = $InformationURL
                        "PrivacyURL" = $PrivacyURL
                        "CompanyPortalFeaturedApp" = $CompanyPortalFeaturedApp
                        "FileName" = $IntuneWinXMLMetaData.ApplicationInfo.FileName
                        "SetupFileName" = $IntuneWinXMLMetaData.ApplicationInfo.SetupFile
                        "InstallExperience" = $InstallExperience
                        "RestartBehavior" = $RestartBehavior
                        "MSIInstallPurpose" = $MSIInstallPurpose
                        "MSIProductCode" = $IntuneWinXMLMetaData.ApplicationInfo.MsiInfo.MsiProductCode
                        "MSIProductName" = $DisplayName
                        "MSIProductVersion" = $IntuneWinXMLMetaData.ApplicationInfo.MsiInfo.MsiProductVersion
                        "MSIRequiresReboot" = $MSIRequiresReboot
                        "MSIUpgradeCode" = $IntuneWinXMLMetaData.ApplicationInfo.MsiInfo.MsiUpgradeCode
                    }
                    if ($PSBoundParameters["Icon"]) {
                        $AppBodySplat.Add("Icon", $Icon)
                    }
                    if ($PSBoundParameters["RequirementRule"]) {
                        $AppBodySplat.Add("RequirementRule", $RequirementRule)
                    }
                    if ($PSBoundParameters["DisplayVersion"]) {
                        $AppBodySplat.Add("DisplayVersion", $DisplayVersion)
                    }

                    $Win32AppBody = New-IntuneWin32AppBody @AppBodySplat
                    Write-Verbose -Message "Constructed the basic layout for 'MSI' Win32 app body type"
                }
                "EXE" {
                    # Generate Win32 application body
                    $AppBodySplat = @{
                        "EXE" = $true
                        "DisplayName" = $DisplayName
                        "Description" = $Description
                        "Publisher" = $Publisher
                        "Developer" = $Developer
                        "Owner" = $Owner
                        "Notes" = $Notes
                        "InformationURL" = $InformationURL
                        "PrivacyURL" = $PrivacyURL
                        "CompanyPortalFeaturedApp" = $CompanyPortalFeaturedApp
                        "FileName" = $IntuneWinXMLMetaData.ApplicationInfo.FileName
                        "SetupFileName" = $IntuneWinXMLMetaData.ApplicationInfo.SetupFile
                        "InstallExperience" = $InstallExperience
                        "RestartBehavior" = $RestartBehavior
                        "InstallCommandLine" = $InstallCommandLine
                        "UninstallCommandLine" = $UninstallCommandLine
                    }
                    if ($PSBoundParameters["Icon"]) {
                        $AppBodySplat.Add("Icon", $Icon)
                    }
                    if ($PSBoundParameters["RequirementRule"]) {
                        $AppBodySplat.Add("RequirementRule", $RequirementRule)
                    }
                    if ($PSBoundParameters["DisplayVersion"]) {
                        $AppBodySplat.Add("DisplayVersion", $DisplayVersion)
                    }

                    $Win32AppBody = New-IntuneWin32AppBody @AppBodySplat
                    Write-Verbose -Message "Constructed the basic layout for 'EXE' Win32 app body type"
                }
            }

            # Validate that correct detection rules have been passed on command line, only 1 PowerShell script based detection rule is allowed
            if (($DetectionRule.'@odata.type' -contains "#microsoft.graph.win32LobAppPowerShellScriptDetection") -and (@($DetectionRules).'@odata.type'.Count -gt 1)) {
                Write-Warning -Message "Multiple PowerShell Script detection rules were detected, this is not a supported configuration"; break
            }
            
            # Add detection rules to Win32 app body object
            Write-Verbose -Message "Detection rule objects passed validation checks, attempting to add to existing Win32 app body"
            $Win32AppBody.Add("detectionRules", $DetectionRule)

            # Retrieve the default return codes for a Win32 app
            Write-Verbose -Message "Retrieving default set of return codes for Win32 app body construction"
            $DefaultReturnCodes = Get-IntuneWin32AppDefaultReturnCode

            # Add custom return codes from parameter input to default set of objects
            if ($PSBoundParameters["ReturnCode"]) {
                Write-Verbose -Message "Additional return codes where passed as command line input, adding to array of default return codes"
                foreach ($ReturnCodeItem in $ReturnCode) {
                    $DefaultReturnCodes += $ReturnCodeItem
                }
            }

            # Add return codes to Win32 app body object
            Write-Verbose -Message "Adding array of return codes to Win32 app body construction"
            $Win32AppBody.Add("returnCodes", $DefaultReturnCodes)

            # Add additional requirement rules to Win32 app body object
            if ($PSBoundParameters["AdditionalRequirementRule"]) {
                $Win32AppBody.Add("requirementRules", $AdditionalRequirementRule)
            }

            # Create the Win32 app
            Write-Verbose -Message "Attempting to create Win32 app using constructed body converted to JSON content"
            $Win32MobileAppRequest = Invoke-IntuneGraphRequest -APIVersion "Beta" -Resource "mobileApps/$ApplicationId" -Method "PATCH" -Body ($Win32AppBody | ConvertTo-Json)
            if ($Win32MobileAppRequest.'@odata.type' -notlike "#microsoft.graph.win32LobApp") {
                Write-Warning -Message "Failed to update Win32 app using constructed body. Passing converted body as JSON to output."; break
                Write-Output -InputObject ($Win32AppBody | ConvertTo-Json)
            }
            else {
                Write-Verbose -Message "Successfully updated Win32 app with ID: $($Win32MobileAppRequest.id)"
            }
        }
        catch [System.Exception] {
            Write-Warning -Message "An error occurred while updating the Win32 application with ID $ApplicationId. Error message: $($_.Exception.Message)"
        }
    }
}