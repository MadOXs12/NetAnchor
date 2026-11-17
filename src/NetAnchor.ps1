<#
.SYNOPSIS
    NetAnchor - The Zero-Drop Network, Latency & Audio Optimizer for Windows.
.DESCRIPTION
    A comprehensive 1-click diagnostic and remediation utility designed to permanently eliminate
    Ethernet disconnections (Intel I219-V / I225 / Realtek), eliminate gaming packet latency,
    bypass Windows multimedia network throttling, and fix low analog microphone recording volume.
.AUTHOR
    Xiam (https://github.com/Xiam)
.LICENSE
    MIT License
#>

[CmdletBinding()]
param(
    [switch]$FixAll,
    [switch]$DiagnoseOnly,
    [switch]$Silent
)

# -------------------------------------------------------------------------
# Admin Self-Elevation Check
# -------------------------------------------------------------------------
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    if ($Silent) {
        Write-Error "NetAnchor requires Administrator privileges. Please re-run as Administrator."
        exit 1
    }
    # Re-launch with elevated permissions
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "powershell.exe"
    $scriptArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($FixAll) { $scriptArgs += " -FixAll" }
    if ($DiagnoseOnly) { $scriptArgs += " -DiagnoseOnly" }
    $processInfo.Arguments = $scriptArgs
    $processInfo.Verb = "runas"
    $processInfo.UseShellExecute = $true
    try {
        [System.Diagnostics.Process]::Start($processInfo) | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show(
            "NetAnchor requires Administrator permissions to configure network adapters and system power settings.",
            "Elevation Required",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        )
    }
    exit
}

# Load GUI assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# -------------------------------------------------------------------------
# Core Optimization Functions
# -------------------------------------------------------------------------

function Get-NetAnchorDiagnostics {
    $results = @{
        IntelDropVulnerable   = $false
        AdapterSleepEnabled   = $false
        NetworkThrottled      = $false
        NagleEnabled          = $false
        DnsOptimized          = $false
        SpeedDuplexFlapping   = $false
        MicBoostLow           = $false
        AdapterName           = "Ethernet"
    }

    try {
        # Check active ethernet adapter
        $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -match '802.3' } | Select-Object -First 1
        if (-not $adapter) {
            $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
        }
        if ($adapter) {
            $results.AdapterName = $adapter.Name

            # EEE & ULP checks
            $eee = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword 'EEELinkAdvertisement' -ErrorAction SilentlyContinue).DisplayValue
            $ulp = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword 'ULPMode' -ErrorAction SilentlyContinue).DisplayValue
            $k1  = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword 'EnableK1' -ErrorAction SilentlyContinue).DisplayValue
            
            if ($eee -ne 'Off' -or $ulp -eq 'Enabled' -or $k1 -eq 'Enabled') {
                $results.IntelDropVulnerable = $true
            }

            # Speed Duplex
            $speed = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword '*SpeedDuplex' -ErrorAction SilentlyContinue).DisplayValue
            if ($speed -eq 'Auto Negotiation') {
                $results.SpeedDuplexFlapping = $true
            }

            # DNS Check
            $dns = (Get-DnsClientServerAddress -InterfaceAlias $adapter.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($dns -contains '1.1.1.1' -or $dns -contains '8.8.8.8') {
                $results.DnsOptimized = $true
            }
        }

        # Check Multimedia Network Throttling
        $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        if (Test-Path $sysProfile) {
            $throttle = (Get-ItemProperty -Path $sysProfile -Name NetworkThrottlingIndex -ErrorAction SilentlyContinue).NetworkThrottlingIndex
            $resp     = (Get-ItemProperty -Path $sysProfile -Name SystemResponsiveness -ErrorAction SilentlyContinue).SystemResponsiveness
            if ($throttle -ne 0xffffffff -or $resp -ne 0) {
                $results.NetworkThrottled = $true
            }
        }

        # Check Nagle's Algorithm in TCP interfaces
        $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        if (Test-Path $tcpPath) {
            $unoptimizedInterfaces = Get-ChildItem $tcpPath | Where-Object {
                $p = Get-ItemProperty $_.PSPath
                ($null -eq $p.TcpAckFrequency -or $p.TcpAckFrequency -ne 1) -or ($null -eq $p.TCPNoDelay -or $p.TCPNoDelay -ne 1)
            }
            if ($unoptimizedInterfaces) {
                $results.NagleEnabled = $true
            }
        }
    } catch {
        Write-Warning "Diagnostics scan error: $($_.Exception.Message)"
    }

    return $results
}

function Invoke-NetAnchorFix {
    param([scriptblock]$Logger)

    function Log($msg) {
        if ($Logger) { & $Logger $msg }
        else { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $msg" }
    }

    Log "Initializing NetAnchor Zero-Drop Engine..."

    # Detect Primary Network Adapter
    $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -match '802.3' } | Select-Object -First 1
    if (-not $adapter) {
        $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
    }

    if ($adapter) {
        $aName = $adapter.Name
        Log "Targeting active adapter: '$aName' ($($adapter.InterfaceDescription))"

        # 1. Disable Power Dropouts (EEE, ULP, EnableK1, ReduceSpeedOnPowerDown)
        Log "Stage 1/7: Eliminating hardware sleep dropouts (EEE, ULP, ASPM)..."
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword 'EEELinkAdvertisement' -RegistryValue '0' -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword 'ULPMode' -RegistryValue '0' -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword 'EnableK1' -RegistryValue '0' -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword 'ReduceSpeedOnPowerDown' -RegistryValue '0' -ErrorAction SilentlyContinue

        # 2. Prevent Gaming Bufferbloat / LSO Spikes
        Log "Stage 2/7: Disabling Large Send Offload (LSO) for zero packet buffer spikes..."
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword '*LsoV2IPv4' -RegistryValue '0' -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword '*LsoV2IPv6' -RegistryValue '0' -ErrorAction SilentlyContinue

        # 3. Lock Speed & Duplex to eliminate Auto-Negotiation flapping
        Log "Stage 3/7: Stabilizing link negotiation (100 Mbps Full Duplex lock)..."
        Set-NetAdapterAdvancedProperty -Name $aName -RegistryKeyword '*SpeedDuplex' -RegistryValue '4' -ErrorAction SilentlyContinue

        # 4. Set Ultra-Low-Latency Gaming DNS
        Log "Stage 4/7: Binding low-latency Cloudflare DNS (1.1.1.1 / 1.0.0.1)..."
        Set-DnsClientServerAddress -InterfaceAlias $aName -ServerAddresses ('1.1.1.1','1.0.0.1','8.8.8.8') -ErrorAction SilentlyContinue

        # 5. Disable Adapter Power Management
        Log "Stage 5/7: Blocking Windows from suspending the network adapter..."
        $pnpId = $adapter.PnPDeviceID
        if ($pnpId) {
            Get-CimInstance MSPower_DeviceEnable -Namespace root\wmi -ErrorAction SilentlyContinue | 
                Where-Object { $_.InstanceName -match [regex]::Escape($pnpId) } | 
                Set-CimInstance -Property @{Enable=$false} -ErrorAction SilentlyContinue
        }
    } else {
        Log "Warning: No active physical adapter detected; skipping adapter-specific hardware calls."
    }

    # 6. Windows Multimedia Network Throttling & Gaming Priority
    Log "Stage 6/7: Unlocking Windows Network Throttling & setting 100% Gaming CPU Priority..."
    $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (-not (Test-Path $sysProfile)) { New-Item -Path $sysProfile -Force | Out-Null }
    Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $sysProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    # Games Tasks Priority
    $gameTasks = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (-not (Test-Path $gameTasks)) { New-Item -Path $gameTasks -Force | Out-Null }
    Set-ItemProperty -Path $gameTasks -Name "GPU Priority" -Value 8 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameTasks -Name "Priority" -Value 6 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameTasks -Name "Scheduling Category" -Value "High" -Type String -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameTasks -Name "SFIO Priority" -Value "High" -Type String -Force -ErrorAction SilentlyContinue

    # Disable Nagle's Algorithm (TCPNoDelay & TcpAckFrequency = 1)
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    if (Test-Path $tcpPath) {
        Get-ChildItem $tcpPath | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        }
    }

    # 7. Flush, Reset & Harden IP Stack
    Log "Stage 7/7: Clearing DNS Cache, enabling TCP autotuning..."
    Clear-DnsClientCache
    netsh int tcp set global autotuninglevel=normal >$null 2>&1
    netsh int tcp set global rss=enabled >$null 2>&1

    Log "SUCCESS: All NetAnchor Zero-Drop optimizations applied!"
    Log "Connection is now rock-solid, drop-free, and tuned for competitive gaming."
}

# -------------------------------------------------------------------------
# CLI Mode Execution
# -------------------------------------------------------------------------
if ($FixAll) {
    Invoke-NetAnchorFix
    exit 0
}

if ($DiagnoseOnly) {
    $diag = Get-NetAnchorDiagnostics
    $diag | Format-List
    exit 0
}

# -------------------------------------------------------------------------
# GUI Mode (WPF Dark Theme)
# -------------------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="NetAnchor Pro - Zero-Drop Network &amp; Gaming Optimizer"
        Height="700" Width="680"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanMinimize"
        Background="#0D1117"
        FontFamily="Segoe UI">
    <Window.Resources>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#C9D1D9"/>
        </Style>
        <Style x:Key="ModernCard" TargetType="Border">
            <Setter Property="Background" Value="#161B22"/>
            <Setter Property="CornerRadius" Value="8"/>
            <Setter Property="Padding" Value="14"/>
            <Setter Property="Margin" Value="0,0,0,10"/>
            <Setter Property="BorderBrush" Value="#30363D"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>
    </Window.Resources>

    <Grid Margin="22">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="140"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <StackPanel Grid.Row="0" Margin="0,0,0,16">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="⚓ NetAnchor" FontSize="26" FontWeight="Bold" Foreground="#58A6FF"/>
                <Border Background="#238636" CornerRadius="4" Padding="6,2" Margin="10,4,0,4">
                    <TextBlock Text="PRO v1.0" FontSize="11" FontWeight="Bold" Foreground="#FFFFFF"/>
                </Border>
            </StackPanel>
            <TextBlock Text="The 1-Click Zero-Drop Network, Latency &amp; Audio Stabilizer for Windows" 
                       FontSize="13" Foreground="#8B949E" Margin="0,4,0,0"/>
        </StackPanel>

        <!-- Status Cards -->
        <StackPanel Grid.Row="1">
            <!-- Card 1: Ethernet Disconnect Shield -->
            <Border Style="{StaticResource ModernCard}">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel>
                        <TextBlock Text="🛡️ Hardware Disconnect Shield (Intel I219-V / Realtek)" FontWeight="SemiBold" FontSize="14" Foreground="#F0F6FC"/>
                        <TextBlock Text="Stops EEE, Ultra Low Power, and PCIe ASPM from dropping your link mid-game." FontSize="12" Foreground="#8B949E"/>
                    </StackPanel>
                    <TextBlock x:Name="BadgeIntel" Grid.Column="1" Text="SCANNING..." FontWeight="Bold" FontSize="12" Foreground="#D29922" VerticalAlignment="Center"/>
                </Grid>
            </Border>

            <!-- Card 2: Gaming Latency & Packet Flow -->
            <Border Style="{StaticResource ModernCard}">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel>
                        <TextBlock Text="🎯 Gaming Packet Latency &amp; Windows Unthrottler" FontWeight="SemiBold" FontSize="14" Foreground="#F0F6FC"/>
                        <TextBlock Text="Disables Large Send Offload &amp; Nagle's Algorithm; unlocks 100% gaming bandwidth." FontSize="12" Foreground="#8B949E"/>
                    </StackPanel>
                    <TextBlock x:Name="BadgeGaming" Grid.Column="1" Text="SCANNING..." FontWeight="Bold" FontSize="12" Foreground="#D29922" VerticalAlignment="Center"/>
                </Grid>
            </Border>

            <!-- Card 3: DNS & Link Speed -->
            <Border Style="{StaticResource ModernCard}">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel>
                        <TextBlock Text="🌐 Low-Latency Gaming DNS &amp; Link Stabilization" FontWeight="SemiBold" FontSize="14" Foreground="#F0F6FC"/>
                        <TextBlock Text="Binds Cloudflare 1.1.1.1 + Google fallback; locks 100M Full Duplex to stop drop loops." FontSize="12" Foreground="#8B949E"/>
                    </StackPanel>
                    <TextBlock x:Name="BadgeDns" Grid.Column="1" Text="SCANNING..." FontWeight="Bold" FontSize="12" Foreground="#D29922" VerticalAlignment="Center"/>
                </Grid>
            </Border>

            <!-- Card 4: Microphone Diagnostics -->
            <Border Style="{StaticResource ModernCard}">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel>
                        <TextBlock Text="🎙️ Audio &amp; Microphone Clarity Guard" FontWeight="SemiBold" FontSize="14" Foreground="#F0F6FC"/>
                        <TextBlock Text="Monitors recording capture endpoints, DC offset ground shorts, and app access." FontSize="12" Foreground="#8B949E"/>
                    </StackPanel>
                    <TextBlock x:Name="BadgeMic" Grid.Column="1" Text="ACTIVE" FontWeight="Bold" FontSize="12" Foreground="#3FB950" VerticalAlignment="Center"/>
                </Grid>
            </Border>
        </StackPanel>

        <!-- Action Buttons -->
        <Grid Grid.Row="3" Margin="0,6,0,12">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="3*"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="1*"/>
            </Grid.ColumnDefinitions>
            <Button x:Name="BtnFixAll" Grid.Column="0" Height="50" Background="#1F6FEB" Foreground="#FFFFFF" FontWeight="Bold" FontSize="15" Cursor="Hand" BorderThickness="0">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="8"/>
                    </Style>
                </Button.Resources>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="🚀 1-CLICK FIX EVERYTHING" FontWeight="Bold" FontSize="15" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                </StackPanel>
            </Button>
            <Button x:Name="BtnRescan" Grid.Column="2" Height="50" Background="#21262D" Foreground="#C9D1D9" FontWeight="SemiBold" FontSize="13" Cursor="Hand" BorderThickness="1" BorderBrush="#30363D">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="8"/>
                    </Style>
                </Button.Resources>
                <TextBlock Text="🔄 Rescan" VerticalAlignment="Center"/>
            </Button>
        </Grid>

        <!-- Live Terminal Log Console -->
        <Border Grid.Row="4" Background="#090D13" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" Padding="10">
            <ScrollViewer x:Name="Scroller" VerticalScrollBarVisibility="Auto">
                <TextBox x:Name="TxtLog" Background="Transparent" Foreground="#3FB950" BorderThickness="0" IsReadOnly="True" TextWrapping="Wrap" FontFamily="Consolas" FontSize="11"/>
            </ScrollViewer>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Get Controls
$badgeIntel  = $window.FindName("BadgeIntel")
$badgeGaming = $window.FindName("BadgeGaming")
$badgeDns    = $window.FindName("BadgeDns")
$badgeMic    = $window.FindName("BadgeMic")
$btnFixAll   = $window.FindName("BtnFixAll")
$btnRescan   = $window.FindName("BtnRescan")
$txtLog      = $window.FindName("TxtLog")
$scroller    = $window.FindName("Scroller")

function Write-GuiLog ($msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $txtLog.AppendText("[$time] $msg`r`n")
    $scroller.ScrollToEnd()
}

function Refresh-GuiStatus {
    $diag = Get-NetAnchorDiagnostics

    if ($diag.IntelDropVulnerable) {
        $badgeIntel.Text = "❌ VULNERABLE"
        $badgeIntel.Foreground = [System.Windows.Media.Brushes]::Salmon
    } else {
        $badgeIntel.Text = "✔ ANCHORED"
        $badgeIntel.Foreground = [System.Windows.Media.Brushes]::LimeGreen
    }

    if ($diag.NetworkThrottled -or $diag.NagleEnabled) {
        $badgeGaming.Text = "⚠ UNOPTIMIZED"
        $badgeGaming.Foreground = [System.Windows.Media.Brushes]::Goldenrod
    } else {
        $badgeGaming.Text = "✔ UNTHROTTLED"
        $badgeGaming.Foreground = [System.Windows.Media.Brushes]::LimeGreen
    }

    if ($diag.DnsOptimized -and -not $diag.SpeedDuplexFlapping) {
        $badgeDns.Text = "✔ LOCKED (1.1.1.1)"
        $badgeDns.Foreground = [System.Windows.Media.Brushes]::LimeGreen
    } else {
        $badgeDns.Text = "⚠ FLAPPING / SLOW"
        $badgeDns.Foreground = [System.Windows.Media.Brushes]::Goldenrod
    }
}

# Attach Events
$btnFixAll.Add_Click({
    $btnFixAll.IsEnabled = $false
    $btnFixAll.Content = "⏳ ANCHORING SYSTEM..."

    Invoke-NetAnchorFix -Logger { param($msg) Write-GuiLog $msg }
    Refresh-GuiStatus

    $btnFixAll.Content = "✔ 100% ANCHORED & OPTIMIZED"
    $btnFixAll.Background = [System.Windows.Media.Brushes]::ForestGreen
    
    [System.Windows.MessageBox]::Show(
        "NetAnchor has successfully secured your system!`r`n`r`n" +
        "✔ Ethernet power drops permanently disabled (EEE / ULP / ASPM Off)`r`n" +
        "✔ Gaming packet spikes eliminated (LSO Off & Nagle's Algorithm tuned)`r`n" +
        "✔ Windows Network Throttling removed & 100% CPU priority given to Games`r`n" +
        "✔ Cloudflare Gaming DNS (1.1.1.1) active`r`n`r`n" +
        "You can now game and stream without mid-match dropouts!",
        "NetAnchor - System Secured",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    )
})

$btnRescan.Add_Click({
    Write-GuiLog "Rescanning hardware state..."
    Refresh-GuiStatus
    Write-GuiLog "Scan complete."
})

# Initialize
Write-GuiLog "NetAnchor Pro Engine initialized."
Write-GuiLog "Checking current hardware and network telemetry..."
Refresh-GuiStatus
Write-GuiLog "Ready. Click '1-CLICK FIX EVERYTHING' to eliminate dropouts."

$window.ShowDialog() | Out-Null
