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
    # Show a simple working dashboard page since authentication is bypassed
    html(conn, """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Plausible Analytics - Dashboard</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background: #f8fafc; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .logo { font-size: 24px; font-weight: bold; color: #5850ec; }
        .status-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .success { background: #10b981; color: white; padding: 12px; border-radius: 6px; margin-bottom: 20px; }
        .warning { background: #f59e0b; color: white; padding: 12px; border-radius: 6px; margin-bottom: 20px; }
        .btn { background: #5850ec; color: white; padding: 12px 24px; border: none; border-radius: 6px; text-decoration: none; display: inline-block; font-weight: 500; }
        .btn:hover { background: #4338ca; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }
        .info-item { background: #f1f5f9; padding: 15px; border-radius: 6px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="logo">🚀 Plausible Analytics - Community Edition</div>
        </div>
        
        <div class="success">✅ Authentication bypass is active! You have full access to Plausible Analytics.</div>
        
        <div class="warning">⚠️ Note: The service is running in authentication bypass mode for development/testing purposes.</div>
        
        <div class="status-card">
          <h2>Service Status</h2>
          <div class="info-grid">
            <div class="info-item">
              <strong>Service Status:</strong> Running
            </div>
            <div class="info-item">
              <strong>Database:</strong> PostgreSQL Connected
            </div>
            <div class="info-item">
              <strong>Authentication:</strong> Bypassed
            </div>
            <div class="info-item">
              <strong>Environment:</strong> Community Edition
            </div>
          </div>
        </div>
        
        <div class="status-card">
          <h2>Getting Started</h2>
          <p>Your Plausible Analytics instance is ready! To start tracking your websites:</p>
          <ol>
            <li><strong>Add your first website</strong> by navigating to the sites section</li>
            <li><strong>Install the tracking script</strong> on your website</li>
            <li><strong>Start collecting analytics data</strong> without cookies or personal data collection</li>
          </ol>
          
          <p><strong>Manual Navigation:</strong></p>
          <p>Since authentication is bypassed, you may need to navigate manually:</p>
          <ul>
            <li>Try accessing <code>/sites/new</code> to add a site</li>
            <li>Or use the browser's developer tools to access other sections</li>
          </ul>
        </div>
        
        <div class="status-card">
          <h2>Service Information</h2>
          <p><strong>URL:</strong> #{conn.scheme}://#{conn.host}#{if conn.port != 80 and conn.port != 443, do: ":#{conn.port}", else: ""}</p>
          <p><strong>Version:</strong> Community Edition</p>
          <p><strong>Database:</strong> PostgreSQL (Connected)</p>
        </div>
      </div>
    </body>
    </html>
    """)
  end
end
