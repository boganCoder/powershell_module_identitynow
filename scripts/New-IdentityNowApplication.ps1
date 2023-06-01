function New-IdentityNowApplication {
	<#
		.SYNOPSIS
		Create an IdentityNow Application.

		.DESCRIPTION
		Create an IdentityNow Application.

		.PARAMETER Name
		(required) The name of the IdentityNow Application create.
		
		.PARAMETER Description
		(required) The description of the IdentityNow Application create.

		.EXAMPLE
		New-IdentityNowApplication -Name "My Application Name" -Description "This was created through PowerShell"

		.LINK
		http://darrenjrobinson.com/sailpoint-identitynow
	#>
	
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Description
    )
	
	# Determine IDN Org Name from connection details
	$idnOrg = Get-IdentityNowOrg
	$idnOrgName = $idnOrg.'Organisation Name'
	
	# Obtain Authorization Token
    $v3Token = Get-IdentityNowAuth

	# If there's a token present
    if ($v3Token.access_token) {
		
        try {
            Write-Verbose "Application Name: $Name"
			
			# Define the required attributes for the creation event
			$body = @{
				"name" = $Name;
				"description" = $Description
			}
			
			# Build the URL string
			$privateuribase = "https://$idnOrgName.api.identitynow.com"
			$url = "$privateuribase/cc/api/app/create"
			
			# Call the IDN webservice
			$response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Body $body -ContentType 'application/x-www-form-urlencoded' -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
			
			# Convert response to JSON
			$application = $response.Content | ConvertFrom-Json
			
			# return value to parent function
			return $application
			
        }
        catch {
			# there's been an issue with calling the IDN web service
            Write-Error "Update to Application failed. Check App ID and update configuration. $($_)" 
        }
    }
    else {
		# No token present, throw an error.
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    }
}
