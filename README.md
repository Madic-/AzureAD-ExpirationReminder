# AzureAD Expiration Reminder Script [![Maintenance](https://img.shields.io/maintenance/yes/2024.svg)]()  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This PowerShell script automates the process of checking for Azure Active Directory (AzureAD) SAML and AzureAD applications whose secrets or certificates are about to expire. It aims to provide an advanced reminder, set by default to 60 days before the expiration date, by sending an email notification containing the details of the expiring entries.

### Example Output

Below is an example of the email notification sent by the script:

```
Subject: AzureAD Expiration Reminder

SAML Application Name: ExampleSAMLApp
Key ID: 12345678-abcd-1234-ef00-123456abcdef
Start Date: 2022-01-01 12:00:00
Expiration Date: 2023-01-01 12:00:00

AzureAD Application Name: ExampleAzureApp
Key ID: 23456789-bcde-2345-fg01-234567bcdefg
Start Date: 2022-02-01 12:00:00
Expiration Date: 2023-02-01 12:00:00
```

## Preparation

Before running the script, ensure you have the required permissions to access the AzureAD applications and their secrets/certificates. The script uses the AzureAD PowerShell module, which can be installed by running the following command:

```powershell
Install-Module -Name AzureAD
```

## Configuration

Before running the script, some variables need to be customized to fit your environment. This includes SMTP configurations for sending emails, as well as the option to authenticate with AzureAD using a certificate for enhanced security (WIP).

### Mandatory Adjustments

1. **SMTP Settings**: The script uses SMTP to send out email notifications. You must provide valid SMTP server details that the script will use to send these emails.

2. **AzureAD Connection (optional / WIP)**: By default, the script connects to AzureAD using an interactive login. For automated scenarios, such as running the script as a scheduled task, certificate-based authentication can instead be used. This requires uncommenting and configuring the relevant section with your AzureAD tenant ID, application ID, and certificate thumbprint.

### Variables Explanation

Below is a detailed explanation of the SMTP-related variables you will need to adjust:

| Variable        | Description |
|-----------------|-------------|
| `$reminderDays` | The number of days in advance to notify users about entries in Azure AD, including SAML and AzureAD applications, that are nearing expiration. Default is set to 60 days before the expiry date. |
| `$smtpServer`   | The hostname or IP address of your SMTP server. |
| `$smtpFrom`     | The email address from which the notifications will be sent. |
| `$smtpTo`       | The recipient email address(es). Separate multiple addresses with commas. |
| `$smtpSubject`  | The subject line of the email notification. |
| `$smtpBody`     | This is dynamically generated by the script but can be customized if required. |
| `$useSmtpAuth`  | Set to `$true` if your SMTP server requires authentication; otherwise, `$false`. |
| `$smtpUsername` | The username for SMTP authentication. Required if `$useSmtpAuth` is `$true`. |
| `$smtpPassword` | The password for SMTP authentication. Required if `$useSmtpAuth` is `$true`. |

### Sending the Notification

The `Send-Notification` function is responsible for sending the email. Depending on your SMTP server's configuration, you might need to adjust the `-UseSsl` parameter or provide additional authentication details.

## Execution

To run the script:

1. Open PowerShell.
2. Navigate to the directory containing the script.
3. Execute the script by running `./AzureAd-Entries.ps1`.

## Security Note

If using SMTP authentication (`$useSmtpAuth = $true`), ensure you secure the script, particularly the `$smtpPassword`, appropriately. Storing passwords in plaintext in scripts is not recommended for production environments.

## Contribution

Feel free to contribute to the script by suggesting improvements or reporting issues. Your feedback is valuable to ensure this tool meets the needs of its users.
