# 自动更新脚本 - 检测文件变更自动推送到GitHub
# 使用方法: 双击 auto-update.bat 启动
# 修改 infinite-rpg.html 并保存后，自动提交并推送

$watchFile = "d:\trea project\1\infinite-rpg.html"
$repoPath = "d:\trea project\1"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  无限流RPG - 自动更新监控已启动" -ForegroundColor Cyan
Write-Host "  监控文件: infinite-rpg.html" -ForegroundColor Yellow
Write-Host "  目标仓库: https://github.com/Bnrfs/infinite-rpg" -ForegroundColor Yellow
Write-Host "  修改文件并保存后自动推送" -ForegroundColor Green
Write-Host "  按 Ctrl+C 停止监控" -ForegroundColor Gray
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 使用FileSystemWatcher监控文件变更
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path $watchFile -Parent
$watcher.Filter = Split-Path $watchFile -Leaf
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::Size

# 用于防抖（避免连续保存触发多次提交）
$lastPush = [DateTime]::MinValue
$debounceSeconds = 5

$action = {
    $now = Get-Date
    $timeSinceLastPush = ($now - $script:lastPush).TotalSeconds
    
    if ($timeSinceLastPush -lt $script:debounceSeconds) {
        return
    }
    
    $script:lastPush = $now
    
    Start-Sleep -Seconds 2  # 等待文件写入完成
    
    $timeStr = $now.ToString("HH:mm:ss")
    Write-Host "[$timeStr] 检测到文件变更，正在提交..." -ForegroundColor Yellow
    
    try {
        Set-Location $using:repoPath
        
        # 检查是否有变更
        $status = git status --porcelain
        if (-not $status) {
            Write-Host "[$timeStr] 文件未实际变更，跳过" -ForegroundColor Gray
            return
        }
        
        git add infinite-rpg.html
        $commitMsg = "自动更新 - $($now.ToString('yyyy-MM-dd HH:mm:ss'))"
        git commit -m $commitMsg
        git push
        
        Write-Host "[$timeStr] 推送成功！网站将在1-2分钟后更新" -ForegroundColor Green
        Write-Host "    网址: https://bnrfs.github.io/infinite-rpg/" -ForegroundColor Cyan
    }
    catch {
        Write-Host "[$timeStr] 推送失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 注册事件
$handle = Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action

Write-Host "监控中... (按 Ctrl+C 停止)" -ForegroundColor Gray

try {
    # 保持脚本运行
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    Unregister-Event -SourceIdentifier $handle.Name -ErrorAction SilentlyContinue
    $watcher.Dispose()
    Write-Host "监控已停止" -ForegroundColor Yellow
}