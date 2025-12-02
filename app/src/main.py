from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse
import os, hashlib, time
from .ddb import put_mapping, get_mapping
from fastapi.responses import HTMLResponse

app = FastAPI()

@app.get("/healthz")
def health():
    return {"status": "ok", "ts": int(time.time())}

@app.post("/shorten")
async def shorten(req: Request):
    body = await req.json()
    url = body.get("url")
    if not url:
        raise HTTPException(400, "url required")
    short = hashlib.sha256(url.encode()).hexdigest()[:8]
    put_mapping(short, url)
    return {"short": short, "url": url}

@app.get("/{short_id}")
def resolve(short_id: str):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(404, "not found")
    return RedirectResponse(item["url"])

@app.get("/", response_class=HTMLResponse)
def homepage():
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>URL Shortener</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f7fc;
                margin: 0;
                padding: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }

            .container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                width: 350px;
                box-shadow: 0 8px 16px rgba(0,0,0,0.1);
                border-top: 6px solid #1e90ff; /* blue highlight */
            }

            h2 {
                text-align: center;
                color: #1e90ff;
                margin-bottom: 20px;
            }

            input {
                width: 100%;
                padding: 12px;
                border: 2px solid #cbd5e1;
                border-radius: 6px;
                margin-bottom: 15px;
                font-size: 14px;
            }

            button {
                width: 100%;
                padding: 12px;
                background: #1e90ff;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 16px;
                cursor: pointer;
            }

            button:hover {
                background: #187bcd;
            }

            .result {
                margin-top: 15px;
                padding: 10px;
                background: #e8f3ff;
                border-left: 4px solid #1e90ff;
                word-break: break-all;
                border-radius: 6px;
                font-size: 14px;
                display: none;
            }
        </style>
    </head>

    <body>
        <div class="container">
            <h2>URL Shortener</h2>

            <input id="urlInput" type="text" placeholder="Enter URL..." />

            <button onclick="shorten()">Shorten URL</button>

            <div id="result" class="result"></div>
        </div>

        <script>
            async function shorten() {
                const url = document.getElementById("urlInput").value;
                const resultBox = document.getElementById("result");
                resultBox.style.display = "none";

                if (!url) {
                    alert("Please enter a URL");
                    return;
                }

                const response = await fetch("/shorten", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({ url })
                });

                const data = await response.json();

                if (data.short) {
                    const shortUrl = `${window.location.origin}/${data.short}`;
                    resultBox.textContent = shortUrl;
                    resultBox.style.display = "block";
                } else {
                    resultBox.textContent = "Error shortening URL";
                    resultBox.style.display = "block";
                }
            }
        </script>
    </body>
    </html>
    """

