# Install-module -Name AzureAD

# Imports the AzureAD Module
Import-Module AzureAD

# Establishes a connection to AzureAD
Connect-AzureAD

# Placeholder for certificate based authentication

#$tenantId = "***"
#$applicationId = "***"
#$thumb = "***"
 
#Connect-AzureAD -TenantId $tenantId -ApplicationId  $applicationId -CertificateThumbprint $thumb

# Sets the number of days before expiration to send the reminder message
$reminderDays = 60

# Gets the current date
$now = Get-Date

# Initializes the list for expiring entries
$expiringEntries = @()

# Function to send the summary of reminders
function Send-Notification {
  param (
    [string[]]$Messages
  )
    
  # SMTP server details. Adjust these settings to match your environment
  $smtpServer = "mail.example.com"
  $smtpFrom = "azuread-expirations@example.com"
  $smtpTo = "recipient@example.com" # You can add more recipients by separating them with commas
  $smtpSubject = "Reminder: AzureAD Entries expiring soon"
  $smtpBody = $Messages -join "`n`n"

  $useSmtpAuth = $true # Set to $false if SMTP authentication is not required
  $smtpUsername = ""
  $smtpPassword = ""

  if ($useSmtpAuth) {
    # Converts the password into a SecureString object
    $securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force

    # Sets the credentials
    $smtpCredentials = New-Object System.Management.Automation.PSCredential ($smtpUsername, $securePassword)

    # Ignores certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Sends the email with authentication
    Send-MailMessage -SmtpServer $smtpServer -From $smtpFrom -To $smtpTo -Subject $smtpSubject -Body $smtpBody -Credential $smtpCredentials -UseSsl

    # Resets the callback function for certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
  }
  else {
    # Ignores certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Sends the email without authentication
    Send-MailMessage -SmtpServer $smtpServer -From $smtpFrom -To $smtpTo -Subject $smtpSubject -Body $smtpBody -UseSsl

    # Resets the callback function for certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
  }
}

# Expiration finding for SAML and AzureAD applications
$SAMLApps = Get-AzureADServicePrincipal -All $true | Where-Object { ($_.Tags -contains "WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1") -or ($_.Tags -contains "WindowsAzureActiveDirectoryCustomSingleSignOnApplication") -or ($_.Tags -contains "WindowsAzureActiveDirectoryIntegratedApp") }

foreach ($App in $SAMLApps) {
  foreach ($KeyCredential in $App.KeyCredentials) {
    if ($KeyCredential.EndDate -lt $now.AddDays($reminderDays)) {
      $expiringEntries += "SAML Application Name: $($App.DisplayName)`nKey ID: $($KeyCredential.KeyId)`nStart Date: $($KeyCredential.StartDate.ToString("yyyy-MM-dd HH:mm:ss"))`nExpiration Date: $($KeyCredential.EndDate.ToString("yyyy-MM-dd HH:mm:ss"))"
    }
  }
}

$applications = Get-AzureADApplication -All $true

foreach ($application in $applications) {
  $secrets = Get-AzureADApplicationPasswordCredential -ObjectId $application.ObjectId
  foreach ($secret in $secrets) {
    if ($null -ne $secret.EndDate -and ($secret.EndDate - $now).TotalDays -lt $reminderDays) {
      $expiringEntries += "AzureAD Application Name: $($application.DisplayName)`nKey ID: $($secret.KeyId)`nStart Date: $($secret.StartDate.ToString("yyyy-MM-dd HH:mm:ss"))`nExpiration Date: $($secret.EndDate.ToString("yyyy-MM-dd HH:mm:ss"))"
    }
  }
}

# Checks if expiring entries exist and then sends an email
if ($expiringEntries.Count -gt 0) {
  Send-Notification -Messages $expiringEntries
}
else {
  Write-Host "No entries expiring soon found." -ForegroundColor Green
}
