# app — local development setup

This README explains how to run and test the local API with an Android device
(Pixel 6a) or emulator and how to override the API base URL when running the
app.

## Quick summary
- The app reads an optional `API_BASE_URL` at build/run time.
- By default Android devices use `http://10.231.227.33:7001` (update this if
	your host IP differs).
- Use `adb reverse` to map device localhost to the host (recommended for local
	dev).

## Run with a custom API base URL (recommended)
Use `--dart-define` to point the app to your machine's IP (or ngrok URL)
without editing code.

Replace `10.231.227.33` below with the host IP you want to use.

Windows (cmd.exe):

```cmd
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.231.227.33:7001
```

This avoids changing source and works well for physical devices on the same
LAN.

## Using adb reverse (fast local mapping)
1. Install Android platform-tools (adb) and ensure `adb` is on your PATH.
2. Connect your Pixel via USB and enable USB debugging.
3. Run:

```cmd
adb devices
adb reverse tcp:7001 tcp:7001
```

4. Run the app (the device's `http://localhost:7001` will now reach the host).

## Test the API from your PC
Use PowerShell to test connectivity and the `/api/auth/login-code` endpoint.

Check port reachability:

```powershell
Test-NetConnection -ComputerName 10.231.227.33 -Port 7001
```

Try the root URL:

```powershell
try {
	$r = Invoke-WebRequest -Uri 'http://10.231.227.33:7001/' -UseBasicParsing -TimeoutSec 5
	Write-Output "OK: $($r.StatusCode)"
} catch {
	Write-Output "ERROR: $($_.Exception.Message)"
}
```

Test the auth endpoint (adjust the `code` if needed):

```powershell
try {
	$body = @{ code = '000000' } | ConvertTo-Json
	$r = Invoke-RestMethod -Uri 'http://10.231.227.33:7001/api/auth/login-code' -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 10
	$r | ConvertTo-Json -Depth 5
} catch {
	Write-Output "ERROR: $($_.Exception.Message)"
}
```

Expected results:
- A JSON response with `token` and `user` when the server accepts the code.
- A 401 or 400 indicates server is reachable but input invalid.
- Timeouts / connection errors indicate network/firewall issues or wrong IP.

## If the device can't reach the server
- Ensure your backend binds to `0.0.0.0` or the host IP, not only `127.0.0.1`.
- Confirm Windows Firewall allows inbound connections on port 7001 (or
	temporarily disable it for testing).
- Use `adb reverse` if you can connect the device via USB.
- Alternatively use `ngrok` to create a public URL.

## Make logging debug-only
The app only enables verbose HTTP logging in debug builds.

## Lint / analyze
To run static checks locally:

```cmd
cd app
flutter analyze
```

---

If you'd like, I can also add a small developer settings screen to switch
base URLs at runtime. Tell me if you want that and I will implement it.
