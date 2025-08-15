Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

function Show-RadioMenu {
    [xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Lo-fi Radio"
    Height="450"
    Width="400"
    WindowStartupLocation="CenterScreen"
    AllowsTransparency="True"
    WindowStyle="None"
    Background="Transparent">
    
    <Window.Resources>
        <Style TargetType="Button" x:Key="StationButton">
            <Setter Property="Background" Value="#CC333333"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Margin" Value="10,5"/>
            <Setter Property="Padding" Value="15"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderThickness="0"
                                CornerRadius="10"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Left"
                                            VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#CC444444"/>
                    <Setter Property="Cursor" Value="Hand"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Border CornerRadius="15" Background="#FF000000" ClipToBounds="True">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Title Bar -->
            <Border Grid.Row="0" Background="#CC222222" CornerRadius="15,15,0,0">
                <Grid x:Name="TitleBar" Background="Transparent" Height="50">
                    <TextBlock Text="Lo-fi Radio" 
                            Foreground="White" 
                            FontSize="20" 
                            Margin="20,0,0,0"
                            VerticalAlignment="Center"
                            FontWeight="Light"/>
                    <Button x:Name="CloseButton" 
                            Content="X" 
                            HorizontalAlignment="Right"
                            VerticalAlignment="Center"
                            Width="40"
                            Height="40"
                            Background="Transparent"
                            Foreground="White"
                            FontSize="20"
                            BorderThickness="0"
                            Margin="0,0,10,0"/>
                </Grid>
            </Border>

            <!-- Radio List -->
            <ScrollViewer Grid.Row="1" Margin="0,10" VerticalScrollBarVisibility="Hidden">
                <StackPanel x:Name="StationsList" Margin="5,0"/>
            </ScrollViewer>

            <!-- Bottom Bar -->
            <Border Grid.Row="2" Background="#CC222222" CornerRadius="0,0,15,15">
                <TextBlock Text="Select a radio to listen"
                         Foreground="#CCCCCC"
                         Margin="20,15"
                         FontSize="12"/>
            </Border>
        </Grid>
    </Border>
</Window>
"@

    # Create window
    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $window = [System.Windows.Markup.XamlReader]::Load($reader)

    # Get UI elements
    $closeButton = $window.FindName("CloseButton")
    $stationsList = $window.FindName("StationsList")
    $titleBar = $window.FindName("TitleBar")

    # Add window drag functionality
    $titleBar.Add_MouseLeftButtonDown({
        $window.DragMove()
    })

    # Add close button functionality
    $closeButton.Add_Click({
        $window.Close()
    })

    # Create a synchronized hashtable to store the result
    $script:selectedStation = $null

    # Add stations to the list
    foreach ($station in $RadioStations.GetEnumerator() | Sort-Object Key) {
        $button = [System.Windows.Controls.Button]@{
            Style = $window.FindResource("StationButton")
        }

        # Create a layout for the button content
        $stackPanel = [System.Windows.Controls.StackPanel]@{
            Orientation = "Vertical"
        }

        $titleBlock = [System.Windows.Controls.TextBlock]@{
            Text = $station.Key
            FontSize = 14
            FontWeight = "SemiBold"
            Margin = "0,0,0,5"
        }

        $stackPanel.Children.Add($titleBlock)
        $button.Content = $stackPanel

        $button.Add_Click({
            param($sender, $e)
            $titleBlock = ($sender.Content.Children | Where-Object { $_.FontWeight -eq "SemiBold" })[0]
            $stationKey = $titleBlock.Text
            $script:selectedStation = $RadioStations[$stationKey]
            $window.Close()
        })

        $stationsList.Children.Add($button)
    }

    # Show window
    $null = $window.ShowDialog()
    
    # Return selected station
    if ($script:selectedStation) {
        return [PSCustomObject]@{
            Name = ($script:selectedStation.Keys)[0]
            Url = $script:selectedStation.Url
        }
    }
    
    return $null
}

# Define default radio with their URLs
$RadioStations = @{
    "Lofi/Relax/Study" = @{
        Url = "https://www.youtube.com/watch?v=jfKfPfyJRdk"
    }
    "Peaceful/Piano/Focus" = @{
        Url = "https://www.youtube.com/watch?v=TtkFsfOP9QI"
    }
    "Dark/Escape/Dream" = @{
        Url = "https://www.youtube.com/watch?v=S_MOd40zlYU"
    }
    "Synthwave/Game" = @{
        Url = "https://www.youtube.com/watch?v=4xDzrJKXOOY"
    }
    "Sleep/Chill" = @{
        Url = "https://www.youtube.com/watch?v=28KRPhVzCus"
    }
}

# Function to display usage help
function Show-Usage {
    param(
        [string]$ErrorMessage
    )
    
    if ($ErrorMessage) {
        Write-Host "Error: $ErrorMessage" -ForegroundColor Red
    }
    
    Write-Host "Usage:"
    Write-Host "    .\lowinfi.ps1 [-Url <url>] [-Keyword <keyword>] [-DisplayMode <mode>]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "    -Url         : Direct YouTube URL to play"
    Write-Host "    -Keyword     : Keyword from default radio names"
    Write-Host "    -DisplayMode : Display mode options:"
    Write-Host "                   'NoVideo'  - Audio only (default)"
    Write-Host "                   'Normal'   - Normal video window"
    Write-Host "                   'TCT'      - Video in terminal using TCT video output driver"
    Write-Host "                   'Menu'     - Show selection menu"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "    .\lowinfi.ps1 -Keyword lofi"
    Write-Host "    .\lowinfi.ps1 -Url 'https://www.youtube.com/watch?v=jfKfPfyJRdk' -DisplayMode Normal"
    Write-Host "    .\lowinfi.ps1 -DisplayMode TCT"
}

# Main function to play the radio
function Start-LofiRadio {
    param(
        [string]$Url,
        [string]$Keyword,
        [ValidateSet("NoVideo", "Normal", "TCT", "Menu")]
        [string]$DisplayMode = "NoVideo"
    )

    # If no URL or keyword provided, show menu
    if (-not $Url -and -not $Keyword -and $DisplayMode -eq "Menu") {
        $selected = Show-RadioMenu
        if ($selected) {
            $Url = $selected.Url
        } else {
            Write-Host "No station selected." -ForegroundColor Yellow
            return
        }
    }

    # Resolve keyword to URL if keyword is provided
    if ($Keyword -and -not $Url) {
        $station = $RadioStations.GetEnumerator() | Where-Object { $_.Key -like "*$Keyword*" } | Select-Object -First 1
        if ($station) {
            $Url = $station.Value.Url
        } else {
            Show-Usage "Invalid keyword: $Keyword"
            return
        }
    }

    if (-not $Url) {
        $selected = Show-RadioMenu
        if ($selected) {
            $Url = $selected.Url
        } else {
            Write-Host "No station selected." -ForegroundColor Yellow
            return
        }
    }

    try {
        # Get stream URL using yt-dlp for YouTube links
        if ($Url -like "*youtube.com*") {
            # For video modes, get best format that includes video
            if ($DisplayMode -eq "Normal" -or $DisplayMode -eq "TCT") {
                $streamUrl = & yt-dlp -f best --get-url $Url
            } else {
                # For audio-only, get best audio format
                $streamUrl = & yt-dlp -f bestaudio[ext=mp4] --get-url $Url
            }
            if ($LASTEXITCODE -ne 0) { throw "Failed to get stream URL" }
        } else {
            $streamUrl = $Url
        }

        # Configure mpv based on display mode
        switch ($DisplayMode) {
            "NoVideo" {
                & mpv --no-video --no-terminal --really-quiet $streamUrl
            }
            "Normal" {
                & mpv --force-window=yes --no-terminal $streamUrl
            }
            "TCT" {
                & mpv --vo=tct --vo-tct-algo=plain --no-terminal $streamUrl
            }
            default {
                & mpv --no-video --no-terminal --really-quiet $streamUrl
            }
        }

        if ($LASTEXITCODE -ne 0) { throw "Failed to play stream" }
    }
    catch {
        Write-Host "Error playing stream: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Parse command line arguments and run the script
$params = @{}

for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        "-Url" { 
            $i++
            $params["Url"] = $args[$i]
        }
        "-Keyword" {
            $i++
            $params["Keyword"] = $args[$i]
        }
        "-DisplayMode" {
            $i++
            $params["DisplayMode"] = $args[$i]
        }
    }
}

# If no arguments provided, show menu by default
if ($args.Count -eq 0) {
    $params["DisplayMode"] = "Menu"
}

Start-LofiRadio @params
