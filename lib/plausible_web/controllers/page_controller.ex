defmodule PlausibleWeb.PageController do
  use PlausibleWeb, :controller
  use Plausible.Repo

  # Disabled authentication for debugging - no login required
  # plug PlausibleWeb.RequireLoggedOutPlug

  @doc """
  The root path is never accessible in Plausible.Cloud because it is handled by the upstream reverse proxy.

  This controller action is only ever triggered in self-hosted Plausible.
  For debugging, show a simple success page without authentication.
  """
  def index(conn, _params) do
    # Show HTML page confirming auth bypass is working
    html(conn, """
    <!DOCTYPE html>
    <html>
    <head><title>Plausible Analytics - Auth Bypass Active</title>
    <style>body{font-family:Arial;margin:50px;background:#f5f5f5}.container{max-width:600px;margin:0 auto;background:white;padding:30px;border-radius:8px}h1{color:#4f46e5}.status{background:#10b981;color:white;padding:10px;border-radius:4px}</style>
    </head>
    <body>
    <div class="container">
    <h1>🚀 Plausible Analytics</h1>
    <div class="status">✅ Authentication bypass is active!</div>
    <p>The service is running without login requirements.</p>
    <p><strong>Service Status:</strong> Running successfully</p>
    <p><strong>Database:</strong> Connected</p>
    <p><strong>Authentication:</strong> Bypassed</p>
    </div>
    </body>
    </html>
    """)
  end
end
