

function Get-TopMostExplorerWindow {

# Helper type for getting windows by class name.
Add-Type -Namespace Util -Name WinApi -MemberDefinition @'
// Find a window by class name and optionally also title.
// The TOPMOST matching window (in terms of Z-order) is returned.
// IMPORTANT: To not search for a title, pass [NullString]::Value, not $null, to lpWindowName

[DllImport("user32.dll")]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
'@
    # Get the topmost File Explorer window, by its class name.
    $hwndTopMostFileExplorer = [Util.WinApi]::FindWindow("CabinetWClass", [NullString]::Value)

    if (-not $hwndTopMostFileExplorer) {
        Write-Warning "There is no open File Explorer window."
        return
    }

    # Using a Shell.Application COM object, locate the window by its hWnd and query its location.

    $explorerWindow = (New-Object -ComObject Shell.Application).Windows() |
    Where-Object hwnd -EQ $hwndTopMostFileExplorer

    # This should normally not happen.
    if (-not $explorerWindow) {
        Write-Warning "The topmost File Explorer window, $hwndTopMostFileExplorer, must have just closed."
        return
    }

    [PSCustomObject]@{
        Window     = $explorerWindow
        WindowHWND = $explorerWindow.HWND
        WindowPath = $explorerWindow.Document.Folder.Self.Path
    }

}


