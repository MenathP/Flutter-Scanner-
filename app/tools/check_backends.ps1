try {
  $r = Invoke-WebRequest -Uri 'http://localhost:7001' -UseBasicParsing -TimeoutSec 5
  Write-Output "localhost:7001 -> $($r.StatusCode)"
} catch {
  Write-Output "localhost:7001 -> ERROR: $($_.Exception.Message)"
}
try {
  $r = Invoke-WebRequest -Uri 'http://10.0.2.2:7001' -UseBasicParsing -TimeoutSec 5
  Write-Output "10.0.2.2:7001 -> $($r.StatusCode)"
} catch {
  Write-Output "10.0.2.2:7001 -> ERROR: $($_.Exception.Message)"
}
