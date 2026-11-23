Add-Type -AssemblyName System.Drawing

function Generate-Screenshots {
    param(
        [int]$width,
        [int]$height,
        [string]$outputDir
    )

    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    $scale = $width / 1290.0

    # Colors
    $colorBurgundy = [System.Drawing.Color]::FromArgb(112, 35, 33) # #702321
    $colorDarkBurgundy = [System.Drawing.Color]::FromArgb(75, 18, 17) # #4B1211
    $colorGold = [System.Drawing.Color]::FromArgb(212, 175, 55) # #D4AF37
    $colorOrange = [System.Drawing.Color]::FromArgb(242, 140, 0) # #F28C00
    $colorLightBg = [System.Drawing.Color]::FromArgb(247, 247, 248) # #F7F7F8
    $colorWhite = [System.Drawing.Color]::White
    $colorDarkText = [System.Drawing.Color]::FromArgb(37, 37, 37)
    $colorGrayText = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $colorCardBorder = [System.Drawing.Color]::FromArgb(230, 230, 230)
    $colorGreen = [System.Drawing.Color]::FromArgb(34, 150, 80)

    $brushBurgundy = New-Object System.Drawing.SolidBrush $colorBurgundy
    $brushDarkBurgundy = New-Object System.Drawing.SolidBrush $colorDarkBurgundy
    $brushGold = New-Object System.Drawing.SolidBrush $colorGold
    $brushOrange = New-Object System.Drawing.SolidBrush $colorOrange
    $brushWhite = New-Object System.Drawing.SolidBrush $colorWhite
    $brushLightBg = New-Object System.Drawing.SolidBrush $colorLightBg
    $brushDarkText = New-Object System.Drawing.SolidBrush $colorDarkText
    $brushGrayText = New-Object System.Drawing.SolidBrush $colorGrayText
    $brushGreen = New-Object System.Drawing.SolidBrush $colorGreen

    $penBorder = New-Object System.Drawing.Pen $colorCardBorder, (2 * $scale)
    $penGold = New-Object System.Drawing.Pen $colorGold, (3 * $scale)
    $penDevice = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(50, 50, 50)), (10 * $scale)

    $fontTitle = [System.Drawing.Font]::new("Arial", [float](46 * $scale), [System.Drawing.FontStyle]::Bold)
    $fontSubtitle = [System.Drawing.Font]::new("Arial", [float](24 * $scale), [System.Drawing.FontStyle]::Regular)
    $fontCategory = [System.Drawing.Font]::new("Arial", [float](18 * $scale), [System.Drawing.FontStyle]::Bold)
    $fontCardHeader = [System.Drawing.Font]::new("Arial", [float](26 * $scale), [System.Drawing.FontStyle]::Bold)
    $fontBody = [System.Drawing.Font]::new("Arial", [float](20 * $scale), [System.Drawing.FontStyle]::Regular)
    $fontSmall = [System.Drawing.Font]::new("Arial", [float](16 * $scale), [System.Drawing.FontStyle]::Regular)
    $fontStatNum = [System.Drawing.Font]::new("Arial", [float](34 * $scale), [System.Drawing.FontStyle]::Bold)
    $fontStatLabel = [System.Drawing.Font]::new("Arial", [float](16 * $scale), [System.Drawing.FontStyle]::Regular)

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    $sfLeft = New-Object System.Drawing.StringFormat
    $sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
    $sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = [System.Drawing.StringAlignment]::Far
    $sfRight.LineAlignment = [System.Drawing.StringAlignment]::Center

    $logoPath = "assets\images\Wincoconnect_logo.png"
    $logoImg = $null
    if (Test-Path $logoPath) {
        $logoImg = [System.Drawing.Image]::FromFile($logoPath)
    }

    $screens = @(
        @{
            Filename = "01_dashboard.png";
            Tagline = "EXCLUSIVE INFRASTRUCTURE NETWORK";
            Title = "EXECUTIVE DASHBOARD";
            Subtitle = "Connect with top leaders & track live multi-crore business metrics";
            Type = "dashboard"
        },
        @{
            Filename = "02_directory.png";
            Tagline = "VERIFIED INDUSTRY LEADERS";
            Title = "MEMBER DIRECTORY";
            Subtitle = "Search civil contractors, architects & structural engineering consultants";
            Type = "directory"
        },
        @{
            Filename = "03_referrals.png";
            Tagline = "HIGH-TICKET REFERRAL EXCHANGE";
            Title = "BUSINESS REFERRALS";
            Subtitle = "Pass, receive & track verified multi-crore contract slips";
            Type = "referrals"
        },
        @{
            Filename = "04_projects.png";
            Tagline = "MEGA INFRASTRUCTURE COLLABORATION";
            Title = "PROJECTS & JV HUB";
            Subtitle = "Build consortiums & joint ventures for major infrastructure tenders";
            Type = "projects"
        },
        @{
            Filename = "05_conclaves.png";
            Tagline = "REGIONAL CHAPTERS & CONCLAVES";
            Title = "CHAPTERS & CONCLAVES";
            Subtitle = "Fortnightly leadership conclaves, agendas & RSVP tracking";
            Type = "conclaves"
        }
    )

    foreach ($sc in $screens) {
        $bmp = New-Object System.Drawing.Bitmap $width, $height
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

        # Background Gradient
        $rectBg = New-Object System.Drawing.Rectangle 0, 0, $width, $height
        $bgGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rectBg, $colorDarkBurgundy, $colorBurgundy, 90.0
        $g.FillRectangle($bgGrad, $rectBg)
        $bgGrad.Dispose()

        # Top Tagline Badge
        $badgeW = 520 * $scale
        $badgeH = 44 * $scale
        $badgeX = ($width - $badgeW) / 2
        $badgeY = 110 * $scale
        $badgeBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(60, 255, 255, 255))
        $g.FillRectangle($badgeBrush, $badgeX, $badgeY, $badgeW, $badgeH)
        $g.DrawRectangle($penGold, $badgeX, $badgeY, $badgeW, $badgeH)
        $badgeRect = New-Object System.Drawing.RectangleF $badgeX, $badgeY, $badgeW, $badgeH
        $g.DrawString($sc.Tagline, $fontCategory, $brushGold, $badgeRect, $sfCenter)
        $badgeBrush.Dispose()

        # Main Headline
        $titleRect = New-Object System.Drawing.RectangleF (50 * $scale), (170 * $scale), ($width - (100 * $scale)), (70 * $scale)
        $g.DrawString($sc.Title, $fontTitle, $brushWhite, $titleRect, $sfCenter)

        # Subtitle
        $subRect = New-Object System.Drawing.RectangleF (80 * $scale), (245 * $scale), ($width - (160 * $scale)), (65 * $scale)
        $g.DrawString($sc.Subtitle, $fontSubtitle, $brushWhite, $subRect, $sfCenter)

        # Phone Frame Mockup
        $phoneW = 1050 * $scale
        $phoneH = 2150 * $scale
        $phoneX = ($width - $phoneW) / 2
        $phoneY = 350 * $scale

        # Phone outer shadow / border
        $g.FillRectangle($brushLightBg, $phoneX, $phoneY, $phoneW, $phoneH)
        $g.DrawRectangle($penDevice, $phoneX, $phoneY, $phoneW, $phoneH)

        # Phone Header (Burgundy App Bar)
        $appBarH = 180 * $scale
        $g.FillRectangle($brushBurgundy, $phoneX, $phoneY, $phoneW, $appBarH)

        # Dynamic Island / Notch
        $islandW = 280 * $scale
        $islandH = 45 * $scale
        $islandX = $phoneX + ($phoneW - $islandW) / 2
        $islandY = $phoneY + (20 * $scale)
        $brushBlack = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Black)
        $g.FillRectangle($brushBlack, $islandX, $islandY, $islandW, $islandH)
        $brushBlack.Dispose()

        # App Bar Content
        if ($logoImg -ne $null) {
            $logoW = 140 * $scale
            $logoH = 45 * $scale
            $g.DrawImage($logoImg, ($phoneX + 50 * $scale), ($phoneY + 95 * $scale), $logoW, $logoH)
        }
        $appTitleRect = New-Object System.Drawing.RectangleF ($phoneX + 210 * $scale), ($phoneY + 95 * $scale), (600 * $scale), (50 * $scale)
        $g.DrawString("WINCO CONNECT", $fontCardHeader, $brushWhite, $appTitleRect, $sfLeft)

        # Content inside screen based on type
        $contentY = $phoneY + $appBarH + (30 * $scale)
        $cardW = $phoneW - (80 * $scale)
        $cardX = $phoneX + (40 * $scale)

        if ($sc.Type -eq "dashboard") {
            # Welcome Banner
            $bannerH = 140 * $scale
            $g.FillRectangle($brushWhite, $cardX, $contentY, $cardW, $bannerH)
            $g.DrawRectangle($penBorder, $cardX, $contentY, $cardW, $bannerH)
            $welRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($contentY + 25 * $scale), ($cardW - 60 * $scale), (40 * $scale)
            $g.DrawString("Welcome, Executive Member!", $fontCardHeader, $brushDarkText, $welRect, $sfLeft)
            $chapRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($contentY + 75 * $scale), ($cardW - 60 * $scale), (35 * $scale)
            $g.DrawString("Bengaluru Titans Chapter | Prime Club Syndicate", $fontBody, $brushGrayText, $chapRect, $sfLeft)

            # 4 Metric Cards (2x2 Grid)
            $gridY = $contentY + $bannerH + (30 * $scale)
            $boxW = ($cardW - (20 * $scale)) / 2
            $boxH = 180 * $scale

            $stats = @(
                @{ Num = "77+"; Label = "Verified Members"; Color = $colorBurgundy },
                @{ Num = "6+"; Label = "Regional Chapters"; Color = $colorOrange },
                @{ Num = "Rs 7.77 Cr"; Label = "Business Generated"; Color = $colorGreen },
                @{ Num = "Rs 10.09 L"; Label = "Avg Referral Value"; Color = $colorGold }
            )

            for ($i = 0; $i -lt 4; $i++) {
                $bx = $cardX + ($i % 2) * ($boxW + (20 * $scale))
                $by = $gridY + [Math]::Floor($i / 2) * ($boxH + (20 * $scale))

                $g.FillRectangle($brushWhite, $bx, $by, $boxW, $boxH)
                $g.DrawRectangle($penBorder, $bx, $by, $boxW, $boxH)

                $brushStat = New-Object System.Drawing.SolidBrush $stats[$i].Color
                $sNumRect = New-Object System.Drawing.RectangleF ($bx + 20 * $scale), ($by + 35 * $scale), ($boxW - 40 * $scale), (50 * $scale)
                $g.DrawString($stats[$i].Num, $fontStatNum, $brushStat, $sNumRect, $sfCenter)
                $brushStat.Dispose()

                $sLblRect = New-Object System.Drawing.RectangleF ($bx + 15 * $scale), ($by + 100 * $scale), ($boxW - 30 * $scale), (40 * $scale)
                $g.DrawString($stats[$i].Label, $fontStatLabel, $brushGrayText, $sLblRect, $sfCenter)
            }

            # Quick Actions Header
            $qaY = $gridY + (2 * $boxH) + (50 * $scale)
            $qaHeaderRect = New-Object System.Drawing.RectangleF $cardX, $qaY, $cardW, (40 * $scale)
            $g.DrawString("Quick Actions & Business Slips", $fontCardHeader, $brushDarkText, $qaHeaderRect, $sfLeft)

            # Quick Action Buttons (4 Horizontal Blocks)
            $btnY = $qaY + (55 * $scale)
            $actions = @("Pass Referral Slip", "Given Referrals", "Received Referrals", "Fortnight Conclave")
            foreach ($act in $actions) {
                $bH = 100 * $scale
                $g.FillRectangle($brushWhite, $cardX, $btnY, $cardW, $bH)
                $g.DrawRectangle($penBorder, $cardX, $btnY, $cardW, $bH)

                # Icon indicator
                $iconBrush = New-Object System.Drawing.SolidBrush $colorBurgundy
                $g.FillRectangle($iconBrush, ($cardX + 25 * $scale), ($btnY + 28 * $scale), (45 * $scale), (45 * $scale))
                $iconBrush.Dispose()

                $bRect = New-Object System.Drawing.RectangleF ($cardX + 90 * $scale), ($btnY + 25 * $scale), ($cardW - 150 * $scale), (50 * $scale)
                $g.DrawString($act, $fontCardHeader, $brushDarkText, $bRect, $sfLeft)

                $arrRect = New-Object System.Drawing.RectangleF ($cardX + $cardW - 70 * $scale), ($btnY + 25 * $scale), (50 * $scale), (50 * $scale)
                $g.DrawString(">", $fontCardHeader, $brushGrayText, $arrRect, $sfCenter)

                $btnY += $bH + (18 * $scale)
            }
        }
        elseif ($sc.Type -eq "directory") {
            # Search Bar
            $searchH = 90 * $scale
            $g.FillRectangle($brushWhite, $cardX, $contentY, $cardW, $searchH)
            $g.DrawRectangle($penBorder, $cardX, $contentY, $cardW, $searchH)
            $sTextRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($contentY + 25 * $scale), ($cardW - 60 * $scale), (40 * $scale)
            $g.DrawString("Search members, categories, chapters...", $fontBody, $brushGrayText, $sTextRect, $sfLeft)

            # Category Chips
            $chipY = $contentY + $searchH + (25 * $scale)
            $chips = @("All Members", "Contractors", "Precast", "Fleet", "Consultants")
            $chipX = $cardX
            foreach ($ch in $chips) {
                $cW = (180 * $scale)
                $cH = (55 * $scale)
                $chipBrush = if ($ch -eq "All Members") { $brushBurgundy } else { $brushWhite }
                $chipTextBrush = if ($ch -eq "All Members") { $brushWhite } else { $brushDarkText }
                $g.FillRectangle($chipBrush, $chipX, $chipY, $cW, $cH)
                $g.DrawRectangle($penBorder, $chipX, $chipY, $cW, $cH)
                $chRect = New-Object System.Drawing.RectangleF $chipX, $chipY, $cW, $cH
                $g.DrawString($ch, $fontCategory, $chipTextBrush, $chRect, $sfCenter)
                $chipX += $cW + (12 * $scale)
            }

            # Member Cards
            $mY = $chipY + (85 * $scale)
            $members = @(
                @{ Name = "Kiran Patil"; Co = "Patil Infra Projects Pvt Ltd"; Cat = "Civil Infrastructure Contractor"; Chap = "Bengaluru Titans" },
                @{ Name = "Harri Kumar"; Co = "Vertex Structural Engineering"; Cat = "Consulting Engineering & Tenders"; Chap = "Coastal Vanguard" },
                @{ Name = "Rajeshwari Gowda"; Co = "Gowda Precast Concretes"; Cat = "Precast Highway Girder Manufacturer"; Chap = "Bengaluru Titans" },
                @{ Name = "Mahesh Deshmukh"; Co = "Deshmukh Earthmovers & Cranes"; Cat = "Heavy Equipment Fleet Owner"; Chap = "Hubli Pioneers" }
            )

            foreach ($m in $members) {
                $mH = 210 * $scale
                $g.FillRectangle($brushWhite, $cardX, $mY, $cardW, $mH)
                $g.DrawRectangle($penBorder, $cardX, $mY, $cardW, $mH)

                # Avatar Circle
                $avatarBrush = New-Object System.Drawing.SolidBrush $colorBurgundy
                $g.FillEllipse($avatarBrush, ($cardX + 30 * $scale), ($mY + 30 * $scale), (100 * $scale), (100 * $scale))
                $avatarBrush.Dispose()

                $initRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($mY + 30 * $scale), (100 * $scale), (100 * $scale)
                $initials = $m.Name.Substring(0, 1)
                $g.DrawString($initials, $fontStatNum, $brushWhite, $initRect, $sfCenter)

                # Info
                $nameRect = New-Object System.Drawing.RectangleF ($cardX + 155 * $scale), ($mY + 25 * $scale), ($cardW - 180 * $scale), (40 * $scale)
                $g.DrawString($m.Name, $fontCardHeader, $brushDarkText, $nameRect, $sfLeft)

                $coRect = New-Object System.Drawing.RectangleF ($cardX + 155 * $scale), ($mY + 70 * $scale), ($cardW - 180 * $scale), (35 * $scale)
                $g.DrawString($m.Co, $fontBody, $brushGrayText, $coRect, $sfLeft)

                $catRect = New-Object System.Drawing.RectangleF ($cardX + 155 * $scale), ($mY + 110 * $scale), ($cardW - 180 * $scale), (35 * $scale)
                $g.DrawString($m.Cat, $fontSmall, $brushBurgundy, $catRect, $sfLeft)

                $mChapRect = New-Object System.Drawing.RectangleF ($cardX + 155 * $scale), ($mY + 150 * $scale), ($cardW - 180 * $scale), (30 * $scale)
                $g.DrawString($m.Chap, $fontSmall, $brushOrange, $mChapRect, $sfLeft)

                $mY += $mH + (20 * $scale)
            }
        }
        elseif ($sc.Type -eq "referrals") {
            # Tabs
            $tabH = 80 * $scale
            $halfW = $cardW / 2
            $g.FillRectangle($brushBurgundy, $cardX, $contentY, $halfW, $tabH)
            $tab1Rect = New-Object System.Drawing.RectangleF $cardX, $contentY, $halfW, $tabH
            $g.DrawString("Given Referrals", $fontCardHeader, $brushWhite, $tab1Rect, $sfCenter)

            $g.FillRectangle($brushWhite, ($cardX + $halfW), $contentY, $halfW, $tabH)
            $g.DrawRectangle($penBorder, ($cardX + $halfW), $contentY, $halfW, $tabH)
            $tab2Rect = New-Object System.Drawing.RectangleF ($cardX + $halfW), $contentY, $halfW, $tabH
            $g.DrawString("Received Referrals", $fontCardHeader, $brushDarkText, $tab2Rect, $sfCenter)

            # Referral Slips
            $refY = $contentY + $tabH + (30 * $scale)
            $slips = @(
                @{ Client = "Metro Line 4 Precast Package"; To = "Gowda Precast Concretes"; Val = "Rs 45,00,000"; Status = "Business Closed (TYFCB)"; StatColor = $colorGreen },
                @{ Client = "National Highway Flyover Foundation"; To = "Patil Infra Projects Pvt Ltd"; Val = "Rs 1,20,00,000"; Status = "Proposal Under Review"; StatColor = $colorOrange },
                @{ Client = "High-Rise Commercial HVAC System"; To = "CoolAir MEP Solutions"; Val = "Rs 28,50,000"; Status = "Client Contacted"; StatColor = $colorBurgundy },
                @{ Client = "Industrial Solar Park Substation"; To = "SunPower Gridworks"; Val = "Rs 65,00,000"; Status = "Business Closed (TYFCB)"; StatColor = $colorGreen }
            )

            foreach ($sl in $slips) {
                $sH = 220 * $scale
                $g.FillRectangle($brushWhite, $cardX, $refY, $cardW, $sH)
                $g.DrawRectangle($penBorder, $cardX, $refY, $cardW, $sH)

                # Client title
                $cRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($refY + 25 * $scale), ($cardW - 60 * $scale), (40 * $scale)
                $g.DrawString($sl.Client, $fontCardHeader, $brushDarkText, $cRect, $sfLeft)

                # To
                $toRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($refY + 75 * $scale), ($cardW - 60 * $scale), (35 * $scale)
                $g.DrawString("Referred To: " + $sl.To, $fontBody, $brushGrayText, $toRect, $sfLeft)

                # Value
                $vRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($refY + 125 * $scale), ($cardW - 250 * $scale), (45 * $scale)
                $g.DrawString("Value: " + $sl.Val, $fontStatNum, $brushBurgundy, $vRect, $sfLeft)

                # Status Badge
                $badgeBrush = New-Object System.Drawing.SolidBrush $sl.StatColor
                $bRect = New-Object System.Drawing.RectangleF ($cardX + $cardW - 280 * $scale), ($refY + 125 * $scale), (250 * $scale), (45 * $scale)
                $g.FillRectangle($badgeBrush, ($cardX + $cardW - 280 * $scale), ($refY + 125 * $scale), (250 * $scale), (45 * $scale))
                $g.DrawString($sl.Status, $fontSmall, $brushWhite, $bRect, $sfCenter)
                $badgeBrush.Dispose()

                $refY += $sH + (20 * $scale)
            }
        }
        elseif ($sc.Type -eq "projects") {
            # Projects Banner
            $projY = $contentY
            $projects = @(
                @{ Title = "Bangalore-Mysore Expressway Package 3"; Lead = "Karnataka State Highway Authority"; Scope = "Rigid Pavement, Bridges & Earthworks"; Cost = "Rs 142.50 Cr"; JV = "Seeking Precast & Paving Partners" },
                @{ Title = "Coastal Marine Terminal & Breakwater"; Lead = "Maritime Infrastructure Board"; Scope = "Piling, Dredging, Tetrapod Placement"; Cost = "Rs 88.00 Cr"; JV = "Seeking Heavy Crane Fleet" },
                @{ Title = "Renewable 250MW Solar Farm Grid"; Lead = "CleanPower India Consortium"; Scope = "Transmission Lines, Inverters & Civil"; Cost = "Rs 64.20 Cr"; JV = "Consortium Formed" }
            )

            foreach ($p in $projects) {
                $pH = 310 * $scale
                $g.FillRectangle($brushWhite, $cardX, $projY, $cardW, $pH)
                $g.DrawRectangle($penBorder, $cardX, $projY, $cardW, $pH)

                $pTRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($projY + 25 * $scale), ($cardW - 60 * $scale), (45 * $scale)
                $g.DrawString($p.Title, $fontCardHeader, $brushDarkText, $pTRect, $sfLeft)

                $pLRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($projY + 75 * $scale), ($cardW - 60 * $scale), (35 * $scale)
                $g.DrawString("Authority: " + $p.Lead, $fontBody, $brushGrayText, $pLRect, $sfLeft)

                $pSRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($projY + 115 * $scale), ($cardW - 60 * $scale), (35 * $scale)
                $g.DrawString("Scope: " + $p.Scope, $fontBody, $brushGrayText, $pSRect, $sfLeft)

                $pCRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($projY + 165 * $scale), ($cardW - 60 * $scale), (45 * $scale)
                $g.DrawString("Estimated Budget: " + $p.Cost, $fontStatNum, $brushBurgundy, $pCRect, $sfLeft)

                # JV Badge
                $jvRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($projY + 230 * $scale), ($cardW - 60 * $scale), (50 * $scale)
                $g.FillRectangle($brushOrange, ($cardX + 30 * $scale), ($projY + 230 * $scale), ($cardW - 60 * $scale), (50 * $scale))
                $g.DrawString($p.JV, $fontCategory, $brushWhite, $jvRect, $sfCenter)

                $projY += $pH + (25 * $scale)
            }
        }
        elseif ($sc.Type -eq "conclaves") {
            # Conclave Events
            $conY = $contentY
            $events = @(
                @{ Name = "Bengaluru Titans - 48th Fortnight Conclave"; Date = "Friday, Dec 05, 2026 | 7:30 AM IST"; Venue = "The Leela Palace, Old Airport Road, Bengaluru"; Topic = "Bidding Consortiums for Mega Infrastructure" },
                @{ Name = "Coastal Vanguard Conclave"; Date = "Thursday, Dec 11, 2026 | 8:00 AM IST"; Venue = "Ocean Pearl, Mangaluru"; Topic = "Marine Infrastructure & Port Modernization" },
                @{ Name = "Hubli Pioneers Regional Meet"; Date = "Wednesday, Dec 17, 2026 | 7:45 AM IST"; Venue = "The Gateway Hotel, Hubballi"; Topic = "Industrial Corridor Highway Expansion" }
            )

            foreach ($ev in $events) {
                $eH = 310 * $scale
                $g.FillRectangle($brushWhite, $cardX, $conY, $cardW, $eH)
                $g.DrawRectangle($penBorder, $cardX, $conY, $cardW, $eH)

                $evTRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($conY + 25 * $scale), ($cardW - 60 * $scale), (45 * $scale)
                $g.DrawString($ev.Name, $fontCardHeader, $brushBurgundy, $evTRect, $sfLeft)

                $evDRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($conY + 80 * $scale), ($cardW - 60 * $scale), (35 * $scale)
                $g.DrawString("Date & Time: " + $ev.Date, $fontBody, $brushDarkText, $evDRect, $sfLeft)

                $evVRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($conY + 125 * $scale), ($cardW - 60 * $scale), (35 * $scale)
                $g.DrawString("Venue: " + $ev.Venue, $fontBody, $brushGrayText, $evVRect, $sfLeft)

                $evTopRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($conY + 165 * $scale), ($cardW - 60 * $scale), (35 * $scale)
                $g.DrawString("Focus: " + $ev.Topic, $fontSmall, $brushOrange, $evTopRect, $sfLeft)

                # RSVP Button
                $rsvpRect = New-Object System.Drawing.RectangleF ($cardX + 30 * $scale), ($conY + 225 * $scale), ($cardW - 60 * $scale), (55 * $scale)
                $g.FillRectangle($brushBurgundy, ($cardX + 30 * $scale), ($conY + 225 * $scale), ($cardW - 60 * $scale), (55 * $scale))
                $g.DrawString("RSVP / Confirm Attendance", $fontCategory, $brushWhite, $rsvpRect, $sfCenter)

                $conY += $eH + (25 * $scale)
            }
        }

        # Save Image
        $filePath = Join-Path $outputDir $sc.Filename
        $bmp.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $g.Dispose()
        $bmp.Dispose()
        Write-Host "Generated: $filePath ($width x $height)"
    }

    if ($logoImg -ne $null) { $logoImg.Dispose() }
}

# 1. Generate for 6.7" / 6.5" Displays (1290 x 2796)
Generate-Screenshots -width 1290 -height 2796 -outputDir "d:\HB\Winco Connect\app_store_assets\screenshots_6.7_inch"

# 2. Generate for 6.1" Displays (1179 x 2556)
Generate-Screenshots -width 1179 -height 2556 -outputDir "d:\HB\Winco Connect\app_store_assets\screenshots_6.1_inch"

