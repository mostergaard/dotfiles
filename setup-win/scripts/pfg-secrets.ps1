$targetPath = 'C:\aws\credentials'
$sourceProfile = 'dev-euc1'


# Ensure the credentials file exists and set permissions
if (-not (Test-Path $targetPath)) {
	New-Item -ItemType File -Path $targetPath -Force | Out-Null
	icacls $targetPath /grant "IIS AppPool\DefaultAppPool:(R)" /T | Out-Null
}


# Export credentials and write to file
$cred = aws configure export-credentials --profile $sourceProfile | ConvertFrom-Json
$content = @"
[default]
aws_access_key_id=$($cred.AccessKeyId)
aws_secret_access_key=$($cred.SecretAccessKey)
aws_session_token=$($cred.SessionToken)
"@


Set-Content -Path $targetPath -Value $content
