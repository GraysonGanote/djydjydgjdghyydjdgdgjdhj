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

$smallCursor = 1
$bigCursor = 3 

$tunnelDuration = 15
$tunnelScaleStep = 0.95
$tunnelDelay = 30 

$cursorDelay = 300 
$cursorStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$dc = [GDI2]::GetDC([IntPtr]::Zero)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
while ($stopwatch.Elapsed.TotalSeconds -lt $tunnelDuration) {

    $w = [math]::Round($screenWidth * $tunnelScaleStep)
    $h = [math]::Round($screenHeight * $tunnelScaleStep)
    $x = [math]::Round(($screenWidth - $w) / 2)
    $y = [math]::Round(($screenHeight - $h) / 2)

    [GDI2]::StretchBlt($dc, $x, $y, $w, $h, $dc, 0, 0, $screenWidth, $screenHeight, $SRCCOPY)

    if ($cursorStopwatch.ElapsedMilliseconds -ge $cursorDelay) {
        $cursorStopwatch.Restart()
        
        if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
            [GDI2]::SystemParametersInfo(8233, $bigCursor, [IntPtr]::Zero, 3)
        } else {
            [GDI2]::SystemParametersInfo(8233, $smallCursor, [IntPtr]::Zero, 3)
        }
    }

    Start-Sleep -Milliseconds $tunnelDelay
}

[GDI2]::ReleaseDC([IntPtr]::Zero, $dc)
[GDI2]::SystemParametersInfo(8233, $smallCursor, [IntPtr]::Zero, 3)
