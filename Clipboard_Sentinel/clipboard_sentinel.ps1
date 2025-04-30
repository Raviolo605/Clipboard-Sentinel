# Clipboard Sentinel - PowerShell Version

Import-Module BurntToast

$global:clipboardContent = ""
$global:logPath = "$env:USERPROFILE\Desktop\clipboard_log.txt"

function Send-Alert($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "$timestamp - $message"
    Write-Host $fullMessage -ForegroundColor Yellow
    New-BurntToastNotification -Text "Clipboard Sentinel", $message
    Add-Content -Path $global:logPath -Value $fullMessage
}

function Match-Pattern($text) {
    if ($text -match '\b(?:[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30})\b') {
        Send-Alert "IBAN detected in clipboard: $text"
    } elseif ($text -match '\b(?:[0-9]{4}[- ]?){3}[0-9]{4}\b') {
        Send-Alert "Credit card number detected: $text"
    } elseif ($text -match '\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b') {
        Send-Alert "Email address copied: $text"
    } elseif ($text -match '\bhttps?://[\w\-\._~:/\?#\[\]@!\$&''\(\)\*\+,;=%]+\b') {
        Send-Alert "URL copied: $text"
    } elseif ($text -match 'token|api[_-]?key|bearer|jwt') {
        Send-Alert "Security-sensitive string detected: $text"
    } else {
        Send-Alert "Clipboard content copied: $text"
    }
}

Add-Type -AssemblyName System.Windows.Forms
while ($true) {
    try {
        $current = [Windows.Forms.Clipboard]::GetText()
        if ($current -and $current -ne $global:clipboardContent) {
            $global:clipboardContent = $current
            Match-Pattern $current
        }
    } catch {
        # clipboard locked by another process, skip
    }
    Start-Sleep -Milliseconds 800
}