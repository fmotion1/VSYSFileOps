function Request-ExplorerRefresh {
    $app = New-Object -ComObject Shell.Application
    $appwin = $app.Windows()

    foreach ($window in $appwin) {
        if($window.Name -eq "File Explorer"){
            $window.Refresh()
        }
    }
}