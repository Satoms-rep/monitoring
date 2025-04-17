

$installDir = "C:\Monitoring"
$windowsExporterVersion = "0.30.0"
$blackboxExporterVersion = "0.24.0"  
$nssmVersion = "2.24"

$windowsExporterUrl = "https://github.com/prometheus-community/windows_exporter/releases/download/v$windowsExporterVersion/windows_exporter-$windowsExporterVersion-amd64.exe"
$blackboxExporterUrl = "https://github.com/prometheus/blackbox_exporter/releases/download/v$blackboxExporterVersion/blackbox_exporter-$blackboxExporterVersion.windows-amd64.zip"
$nssmUrl = "https://nssm.cc/release/nssm-$nssmVersion.zip"

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force
}

function Download-File {
    param ($url, $output)
    try {
        Write-Host "Скачивание $url..."
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        return $true
    }
    catch {
        Write-Host "Ошибка при скачивании $url : $_"
        return $false
    }
}

$nssmArchive = "$installDir\nssm.zip"
$nssmPath = "$installDir\nssm.exe"
if (Download-File -url $nssmUrl -output $nssmArchive) {
    Expand-Archive -Path $nssmArchive -DestinationPath $installDir -Force
    Copy-Item "$installDir\nssm-$nssmVersion\win64\nssm.exe" $nssmPath
    Remove-Item $nssmArchive -Force
    Remove-Item "$installDir\nssm-$nssmVersion" -Recurse -Force
}

function Install-Service {
    param($name, $path, $args)
    if (Test-Path $nssmPath) {
        & $nssmPath install $name $path
        & $nssmPath set $name AppParameters $args
        & $nssmPath set $name AppDirectory $installDir
        & $nssmPath set $name Start SERVICE_AUTO_START
        & $nssmPath start $name
    } else {
        $service = New-Service -Name $name -BinaryPathName "$path $args" -StartupType Automatic
        Start-Service -Name $name
    }
}

$windowsExporterPath = "$installDir\windows_exporter.exe"
if (Download-File -url $windowsExporterUrl -output $windowsExporterPath) {
    Write-Host "Установка Windows Exporter..."
    Install-Service -name "windows_exporter" -path $windowsExporterPath -args "--collectors.enabled cpu,memory,disk,net,os --web.listen-address :9182"
}

$blackboxArchive = "$installDir\blackbox_exporter.zip"
if (Download-File -url $blackboxExporterUrl -output $blackboxArchive) {
    Expand-Archive -Path $blackboxArchive -DestinationPath $installDir -Force
    Move-Item "$installDir\blackbox_exporter-$blackboxExporterVersion.windows-amd64\blackbox_exporter.exe" "$installDir\blackbox_exporter.exe" -Force
    Remove-Item $blackboxArchive -Force
    Remove-Item "$installDir\blackbox_exporter-$blackboxExporterVersion.windows-amd64" -Recurse -Force
    
    @"
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_status_codes: [200]
      no_follow_redirects: false
"@ | Out-File "$installDir\blackbox.yml" -Encoding utf8

    Write-Host "Установка Blackbox Exporter..."
    Install-Service -name "blackbox_exporter" -path "$installDir\blackbox_exporter.exe" -args "--config.file=$installDir\blackbox.yml --web.listen-address :9115"
}

Write-Host "Настройка брандмауэра..."
New-NetFirewallRule -DisplayName "Windows Exporter" -Direction Inbound -LocalPort 9182 -Protocol TCP -Action Allow -Enabled True
New-NetFirewallRule -DisplayName "Blackbox Exporter" -Direction Inbound -LocalPort 9115 -Protocol TCP -Action Allow -Enabled True

Write-Host "Установка завершена!"
Write-Host "Windows Exporter: http://$env:COMPUTERNAME:9182/metrics"
Write-Host "Blackbox Exporter: http://$env:COMPUTERNAME:9115/metrics"