# 自动更新脚本 - 检测文件变更自动推送到GitHub
# 通过轮询方式检测文件变更（比FileSystemWatcher更可靠）
param(
    [string]$WatchFile = "index.html",
    [int]$CheckInterval = 3
)

$script:repoPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$watchPath = Join-Path $script:repoPath $WatchFile

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  无限流RPG - 自动更新监控" -ForegroundColor Cyan
Write-Host "  监控文件: $WatchFile" -ForegroundColor Yellow
Write-Host "  修改文件并保存后自动提交推送" -ForegroundColor Green
Write-Host "  按 Ctrl+C 停止监控" -ForegroundColor Gray
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $watchPath)) {
    Write-Host "[错误] 找不到文件: $watchPath" -ForegroundColor Red
    Write-Host "按任意键退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 获取初始修改时间
$lastModified = (Get-Item $watchPath).LastWriteTime
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 监控已启动，初始时间: $lastModified" -ForegroundColor Gray
Write-Host ""

$isRunning = $true

function Push-ToGitHub {
    $timeStr = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timeStr] 检测到文件变更，正在提交..." -ForegroundColor Yellow
    
    try {
        Set-Location $script:repoPath
        
        # 检查git状态
        $status = & git status --porcelain 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[$timeStr] Git错误: $status" -ForegroundColor Red
            return
        }
        
        if (-not $status) {
            Write-Host "[$timeStr] 文件未实际变更，跳过" -ForegroundColor Gray
            return
        }
        
        & git add $WatchFile
        $commitMsg = "自动更新 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        & git commit -m $commitMsg 2>&1 | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[$timeStr] 提交失败（可能无变更）" -ForegroundColor Gray
            return
        }
        
        & git push
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$timeStr] 推送成功！" -ForegroundColor Green
            Write-Host "    网址: https://bnrfs.github.io/infinite-rpg/" -ForegroundColor Cyan
        } else {
            Write-Host "[$timeStr] 推送失败，请检查网络连接" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[$timeStr] 错误: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 主循环 - 轮询检查文件修改时间
try {
    while ($isRunning) {
        if (Test-Path $watchPath) {
            $currentModified = (Get-Item $watchPath).LastWriteTime
            if ($currentModified -gt $lastModified) {
                $lastModified = $currentModified
                Start-Sleep -Seconds 1  # 等待文件写入完成
                Push-ToGitHub
            }
        }
        Start-Sleep -Seconds $CheckInterval
    }
}
catch {
    Write-Host ""
    Write-Host "监控已停止" -ForegroundColor Yellow
}
finally {
    Write-Host "监控已停止。按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}