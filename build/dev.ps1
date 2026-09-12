$port = $env:WAILS_VITE_PORT
if (-not $port) {
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
    $listener.Start()
    $port = $listener.LocalEndpoint.Port
    $listener.Stop()
}

$env:WAILS_VITE_PORT = $port
Write-Host "Using frontend dev server http://127.0.0.1:$port"
& wails3 dev -config ./build/config.yml -port $port
exit $LASTEXITCODE
