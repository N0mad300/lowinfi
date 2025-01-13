# lowinfi

lowinfi is a simple PowerShell script intended to play lofi radio.

Actually it can play any Youtube video or stream, either just audio or with video through `mpv` (you can even play the video in the terminal using `tct` video output driver)

## Disclaimer

The default lofi radio proposed are all from the [Lofi Girl Youtube channel streams](https://www.youtube.com/@LofiGirl/streams), the music from those streams are under their [licensing guidelines](https://form.lofigirl.com/CommercialLicense).

## Usage

```
> .\lowinfi.ps1 [-Url <url>] [-Keyword <keyword>] [-DisplayMode <mode>]
```

Execute the script without specifying a `-Keyword` or an `-Url` will open the GUI selector to choose a radio to play from the default ones.
```
> .\lowinfi.ps1
```
![GUI_selector](images/GUI_Selector.png)

You can specify to play a specific Youtube video or stream from his URL
```
.\lowinfi.ps1 -Url https://www.youtube.com/watch?v=jfKfPfyJRdk
```

You can also play one of the default radio by specifying a `-Keyword`, it will try to find the default radio with this keyword in his name
```
.\lowinfi.ps1 -Keyword lofi
```

By default only the audio of the lofi radio/video/stream 
will be play from the terminal but there is two others `-DisplayMode` available
```
.\lowinfi.ps1 -DisplayMode Normal
```
![Normal](images/Normal.png)

```
.\lowinfi.ps1 -DisplayMode Ascii
```
![Ascii](images/Ascii.png)