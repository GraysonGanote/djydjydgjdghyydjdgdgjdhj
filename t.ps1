Add-Type -AssemblyName System.Windows.Forms

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class GDI2 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetDC(IntPtr hwnd);

    [DllImport("gdi32.dll")]
    public static extern bool StretchBlt(IntPtr hdcDest, int xDest, int yDest, int wDest, int hDest,
                                         IntPtr hdcSrc, int xSrc, int ySrc, int wSrc, int hSrc, uint rop);

    [DllImport("user32.dll")]
    public static extern int ReleaseDC(IntPtr hwnd, IntPtr hdc);

    [DllImport("user32.dll", EntryPoint="SystemParametersInfoW")]
    public static extern bool SystemParametersInfo(uint a, uint u, IntPtr p, uint f);
}
"@

$SRCCOPY = 0x00CC0020
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

$tunnelDuration = 15
$tunnelScaleStep = 0.95
$tunnelDelay = 30 

$loopState = 0

$dc = [GDI2]::GetDC([IntPtr]::Zero)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

while ($loopState -eq 0) {
    
    while ($stopwatch.Elapsed.TotalSeconds -lt $tunnelDuration) {
        $w = [math]::Round($screenWidth * $tunnelScaleStep)
        $h = [math]::Round($screenHeight * $tunnelScaleStep)
        $x = [math]::Round(($screenWidth - $w) / 2)
        $y = [math]::Round(($screenHeight - $h) / 2)

        [GDI2]::StretchBlt($dc, $x, $y, $w, $h, $dc, 0, 0, $screenWidth, $screenHeight, $SRCCOPY)
        Start-Sleep -Milliseconds $tunnelDelay
    }
    $loopState = 1
}
Clear-Host
Clear-Host

[GDI2]::ReleaseDC([IntPtr]::Zero, $dc)
[GDI2]::SystemParametersInfo(8233, $smallCursor, [IntPtr]::Zero, 3)

Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class GDIRefresh {
    [DllImport("user32.dll")] public static extern bool InvalidateRect(IntPtr hWnd, IntPtr lpRect, bool bErase);
}'
[GDIRefresh]::InvalidateRect([IntPtr]::Zero, [IntPtr]::Zero, $true)
[GDIRefresh]::InvalidateRect([IntPtr]::Zero, [IntPtr]::Zero, $true)
[GDIRefresh]::InvalidateRect([IntPtr]::Zero, [IntPtr]::Zero, $true)
[GDIRefresh]::InvalidateRect([IntPtr]::Zero, [IntPtr]::Zero, $true)

Write-Output "Finished"
Start-Sleep 1
Clear-Host
Clear-Host
exit
