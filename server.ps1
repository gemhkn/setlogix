$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:3000/")
$listener.Start()
Write-Host "Server started on http://localhost:3000"

$root = "c:\Users\1 2 A SINIF\Desktop\yeni"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".webp" = "image/webp"
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $req = $context.Request
    $res = $context.Response

    $localPath = $req.Url.LocalPath
    if ($localPath -eq "/") { $localPath = "/index.html" }
    
    $filePath = Join-Path $root ($localPath.TrimStart("/").Replace("/", "\"))
    
    if (Test-Path $filePath -PathType Leaf) {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $ext = [System.IO.Path]::GetExtension($filePath)
        if ($mimeTypes.ContainsKey($ext)) {
            $res.ContentType = $mimeTypes[$ext]
        } else {
            $res.ContentType = "application/octet-stream"
        }
        $res.ContentLength64 = $content.Length
        $res.OutputStream.Write($content, 0, $content.Length)
    } else {
        $res.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("Not Found: $localPath")
        $res.OutputStream.Write($msg, 0, $msg.Length)
    }
    
    $res.Close()
    Write-Host "$($req.HttpMethod) $localPath -> $($res.StatusCode)"
}
