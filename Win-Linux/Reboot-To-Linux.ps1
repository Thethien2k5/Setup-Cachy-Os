param(
    [switch]$DryRun,
    [switch]$DiagnoseOnly
)

# Thiet lap giao dien Console UTF-8 va tieu de
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Chuyen khoi dong sang Linux - NttDz"

$LogFile = "F:\A_Tool\NttDz\reboot_debug.log"
$BcdDumpFile = "F:\A_Tool\NttDz\bcd_firmware.txt"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host $Message -ForegroundColor $Color
}

function Check-IsAdmin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 0. Kiem tra va yeu cau quyen Administrator
if (-not (Check-IsAdmin)) {
    Write-Host "================================================================" -ForegroundColor Yellow
    Write-Host " [!] Dang yeu cau quyen Administrator..." -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Yellow
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($DryRun) { $argList += " -DryRun" }
    if ($DiagnoseOnly) { $argList += " -DiagnoseOnly" }
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    exit
}

Clear-Host
"" | Out-File -FilePath $LogFile -Encoding UTF8
Write-Log "================================================================" "Cyan"
Write-Log "   HE THONG KHOI DONG VA CHUYEN SANG LINUX (O DIA ROI)          " "Cyan"
Write-Log "================================================================" "Cyan"
Write-Log ""

# 1. Kiem tra o dia roi Linux
function Get-LinuxUsbDisk {
    $usbDisks = Get-Disk | Where-Object { $_.BusType -eq 'USB' }
    foreach ($disk in $usbDisks) {
        $parts = Get-Partition -DiskNumber $disk.Number -ErrorAction SilentlyContinue
        $hasLinuxPart = $parts | Where-Object { $_.GptType -eq '{0fc63daf-8483-4772-8e79-3d69d8477de4}' }
        if ($hasLinuxPart -or ($disk.FriendlyName -like '*JMicron*')) {
            return $disk
        }
    }
    return $null
}

Write-Log "[1/4] Kiem tra ket noi o dia roi Linux..." "Yellow"

$linuxDisk = Get-LinuxUsbDisk
while ($null -eq $linuxDisk) {
    Write-Log "" "Yellow"
    Write-Log " [!] CANH BAO: CHUA TIM THAY O DIA ROI LINUX!" "Red"
    Write-Log "     O dia roi USB chua duoc cam hoac may tinh chua nhan dien." "Yellow"
    Write-Log "" "Yellow"
    Write-Log " -> Vui long cam o dia roi vao cong USB va nhan ENTER de kiem tra lai." "Green"
    Write-Log " -> Hoac go 'Q' roi nhan ENTER de huy bo thao tac." "Gray"
    $choice = Read-Host " Lua chon cua ban"
    if ($choice -match '^[Qq]') {
        Write-Log " Da huy bo thao tac theo yeu cau cua nguoi dung." "Yellow"
        Start-Sleep -Seconds 2
        exit
    }
    Start-Sleep -Milliseconds 500
    $linuxDisk = Get-LinuxUsbDisk
}

$sizeGB = [math]::Round($linuxDisk.Size / 1GB, 1)
Write-Log " [OK] Da ket noi: $($linuxDisk.FriendlyName) (Disk #$($linuxDisk.Number), Dung luong: $sizeGB GB)" "Green"

# 1.1 Gan thu o dia tam thoi cho phan vung EFI cua o roi de kiem tra file boot .efi
$tempLetter = "Z"
$efiPart = Get-Partition -DiskNumber $linuxDisk.Number | Where-Object { $_.Type -eq 'System' -or $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' } | Select-Object -First 1

$efiBootFile = ""
$mountedTemp = $false

if ($efiPart) {
    Write-Log " [*] Tim thay phan vung EFI tren o roi: Partition #$($efiPart.PartitionNumber)" "Cyan"
    if (-not $efiPart.DriveLetter) {
        try {
            Set-Partition -DiskNumber $linuxDisk.Number -PartitionNumber $efiPart.PartitionNumber -NewDriveLetter $tempLetter -ErrorAction Stop
            $mountedTemp = $true
            Start-Sleep -Milliseconds 500
            $espPath = "$($tempLetter):"
        } catch {
            Write-Log " [!] Khong the gan o dia $tempLetter cho EFI partition: $_" "Yellow"
            $espPath = ""
        }
    } else {
        $espPath = "$($efiPart.DriveLetter):"
    }

    if ($espPath -and (Test-Path $espPath)) {
        # Tim file .efi tren phan vung nay
        $candidates = @(
            "\EFI\ubuntu\shimx64.efi",
            "\EFI\ubuntu\grubx64.efi",
            "\EFI\arch\grubx64.efi",
            "\EFI\fedora\shimx64.efi",
            "\EFI\fedora\grubx64.efi",
            "\EFI\debian\grubx64.efi",
            "\EFI\pop\systemd-bootx64.efi",
            "\EFI\BOOT\BOOTX64.EFI"
        )
        foreach ($c in $candidates) {
            if (Test-Path "$espPath$c") {
                $efiBootFile = $c
                break
            }
        }
        if (-not $efiBootFile) {
            # Quet toan bo file .efi
            $allEfi = Get-ChildItem -Path "$espPath\EFI" -Recurse -Filter "*.efi" -ErrorAction SilentlyContinue
            if ($allEfi) {
                $chosen = $allEfi | Where-Object { $_.Name -ne "bootmgfw.efi" } | Select-Object -First 1
                if ($chosen) {
                    $efiBootFile = $chosen.FullName.Substring(2)
                }
            }
        }
        if ($efiBootFile) {
            Write-Log " [OK] Phat hien bootloader Linux: $efiBootFile tren ESP" "Green"
        }
    }
}

# 2. Don sach & toi uu he dieu hanh Windows truoc khi sang Linux
Write-Log "" "White"
Write-Log "[2/4] Don sach & toi uu he dieu hanh Windows..." "Yellow"

# A. Tat Fast Startup (HiberbootEnabled = 0) & Hibernate
try {
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -Force -ErrorAction SilentlyContinue
    & powercfg.exe /h off 2>$null
    Write-Log " [OK] Da tat Fast Startup & Hibernate (chong khoa phan vung NTFS / loi dirty flag tren Linux)." "Green"
} catch {
    Write-Log " [!] Canh bao Fast Startup: $_" "Yellow"
}

# B. Dong bo gio BIOS/RTC sang UTC (chong lech gio giua Windows va Linux)
try {
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' -Name 'RealTimeIsUniversal' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Log " [OK] Da dong bo gio BIOS/RTC sang UTC (chong lech 7 tieng khi sang Linux)." "Green"
} catch {}

# C. Xa bo nho dem ghi dia toan bo cac phan vung (Flush cache)
Write-Log " [OK] Dang commit va xa bo nho dem ghi dia..." "Green"
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# 3. Cau hinh bootsequence trong UEFI
Write-Log "" "White"
Write-Log "[3/4] Cau hinh khoi dong UEFI sang Linux..." "Yellow"

# Xuat danh sach bcdedit /enum firmware de phan tich
& bcdedit.exe /enum firmware > $BcdDumpFile
$bcdOutput = Get-Content $BcdDumpFile -Encoding UTF8 -ErrorAction SilentlyContinue

$fallbackGuid = "{b8d3a654-878b-11f1-8026-806e6f6e6963}"
$targetGuid = ""
$targetDesc = ""

if ($bcdOutput) {
    $curId = ""
    $curDesc = ""
    $curPath = ""
    $curDevice = ""

    $entries = @()
    foreach ($line in $bcdOutput) {
        if ($line -match '^\s*identifier\s+({[a-fA-F0-9\-]+})') {
            if ($curId -and $curId -ne "{fwbootmgr}") {
                $entries += [PSCustomObject]@{
                    Id = $curId
                    Desc = $curDesc
                    Path = $curPath
                    Device = $curDevice
                }
            }
            $curId = $matches[1]
            $curDesc = ""
            $curPath = ""
            $curDevice = ""
        }
        elseif ($line -match '^\s*description\s+(.+)$') {
            $curDesc = $matches[1].Trim()
        }
        elseif ($line -match '^\s*path\s+(.+)$') {
            $curPath = $matches[1].Trim()
        }
        elseif ($line -match '^\s*device\s+(.+)$') {
            $curDevice = $matches[1].Trim()
        }
    }
    if ($curId -and $curId -ne "{fwbootmgr}") {
        $entries += [PSCustomObject]@{
            Id = $curId
            Desc = $curDesc
            Path = $curPath
            Device = $curDevice
        }
    }

    Write-Log " [*] Danh sach cac muc boot UEFI tim thay trong firmware:" "Cyan"
    foreach ($e in $entries) {
        Write-Log "     - $($e.Id): '$($e.Desc)' (Path: $($e.Path))" "Gray"
    }

    # Uu tien 1: Tim muc co description hoac path khop voi Linux
    foreach ($e in $entries) {
        $descLower = $e.Desc.ToLower()
        $pathLower = $e.Path.ToLower()
        if ($descLower -match '(ubuntu|linux|grub|arch|fedora|debian|pop|kali|manjaro|jmicron|uefi os)' -or
            $pathLower -match '(ubuntu|linux|grub|arch|fedora|debian|shim|systemd)') {
            if ($e.Id -ne "{bootmgr}") {
                $targetGuid = $e.Id
                $targetDesc = $e.Desc
                Write-Log " [OK] Phat hien Firmware Entry phu hop: $($e.Id) ('$($e.Desc)')" "Green"
                break
            }
        }
    }

    # Uu tien 2: Neu khong co entry nao khop tu khoa, kiem tra fallback GUID
    if (-not $targetGuid) {
        $existsFallback = $entries | Where-Object { $_.Id -eq $fallbackGuid }
        if ($existsFallback) {
            $targetGuid = $fallbackGuid
            $targetDesc = $existsFallback.Desc
            Write-Log " [*] Su dung fallback GUID co san: $fallbackGuid ('$targetDesc')" "Cyan"
        }
    }
}

# Neu van khong co entry hop le hoac entry bi thieu tren BCD, tao moi 1 entry chi dinh truc tiep file EFI tren o roi
if (-not $targetGuid -and $efiBootFile -and $mountedTemp) {
    Write-Log " [*] Khong tim thay entry Linux san co trong NVRAM. Dang tao moi entry BCD cho Linux USB..." "Cyan"
    try {
        $copyOut = & bcdedit.exe /copy "{bootmgr}" /d "Linux External USB"
        if ($copyOut -match '({[a-fA-F0-9\-]+})') {
            $newGuid = $matches[1]
            & bcdedit.exe /set $newGuid path $efiBootFile
            & bcdedit.exe /set $newGuid device "partition=$($tempLetter):"
            & bcdedit.exe /set "{fwbootmgr}" displayorder $newGuid /addlast
            $targetGuid = $newGuid
            $targetDesc = "Linux External USB"
            Write-Log " [OK] Da tao thanh cong entry UEFI moi: $targetGuid" "Green"
        }
    } catch {
        Write-Log " [!] Khong the tao entry BCD moi: $_" "Yellow"
    }
}

# Go bo o dia tam thoi
if ($mountedTemp) {
    try {
        Remove-PartitionAccessPath -DiskNumber $linuxDisk.Number -PartitionNumber $efiPart.PartitionNumber -AccessPath "$($tempLetter):\" -ErrorAction SilentlyContinue
    } catch {}
}

if (-not $targetGuid) {
    $targetGuid = $fallbackGuid
    Write-Log " [!] Khong tim duoc GUID ro rang, su dung GUID mac dinh: $targetGuid" "Yellow"
}

Write-Log " [*] GUID duoc chon de boot: $targetGuid ($targetDesc)" "Cyan"

if ($DiagnoseOnly) {
    Write-Log "" "White"
    Write-Log "=== CHE DO CHAN DOAN (DIAGNOSE ONLY) HOAN TAT ===" "Green"
    Write-Log "Thong tin chi tiet da duoc ghi vao file:" "Cyan"
    Write-Log " - $LogFile" "Cyan"
    Write-Log " - $BcdDumpFile" "Cyan"
    Write-Host "`nNhan phim bat ky de dong cua so..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

if (-not $DryRun) {
    # Thiet lap ca 2 lenh bootsequence
    $res1 = & bcdedit.exe /set "{fwbootmgr}" bootsequence $targetGuid 2>&1
    $res2 = & bcdedit.exe /bootsequence $targetGuid 2>&1

    Write-Log " [OK] Lenh bcdedit /set {fwbootmgr} bootsequence: $res1" "Green"
    Write-Log " [OK] Lenh bcdedit /bootsequence: $res2" "Green"

    Write-Log "" "White"
    Write-Log "================================================================" "Green"
    Write-Log " [OK] DA CAU HINH XONG! MAY TINH SE KHOI DONG VAO LINUX." "Green"
    Write-Log "================================================================" "Green"
    Write-Log "LUU Y QUAN TRONG VOI MAINBOARD ASUS:" "Yellow"
    Write-Log "Neu may khoi dong lai van vao Win, nguyen nhan la tinh nang Fast Boot" "Yellow"
    Write-Log "trong BIOS cua ASUS da bo qua khoi tao cong USB khi boot!" "Yellow"
    Write-Log "-> Khac phuc 1 lan duy nhat: Vao BIOS (an F2/Del khi bat may) -> Boot -> Fast Boot: Disabled." "Cyan"
    Write-Log "================================================================" "Green"
    Write-Log "" "White"

    Write-Host "He thong se khoi dong lai sau 3 giay (Nhan Ctrl+C neu muon huy)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3

    & shutdown.exe /r /f /t 0
} else {
    Write-Log "[DRY RUN] Hoan tat toan bo quy trinh (khong reboot)!" "Green"
}
