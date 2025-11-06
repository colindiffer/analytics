defmodule PlausibleWeb.PageController do
  use PlausibleWeb, :controller
  use Plausible.Repo
  alias Plausible.Sites

  # Disabled authentication for debugging - no login required
  # plug PlausibleWeb.RequireLoggedOutPlug

  @doc """
  The root path is never accessible in Plausible.Cloud because it is handled by the upstream reverse proxy.

  This controller action is only ever triggered in self-hosted Plausible.
  For debugging, show a dashboard with real sites from the database.
  """
  def index(conn, _params) do
    # Get real sites from the database
    sites = from(s in Plausible.Site, select: %{domain: s.domain, inserted_at: s.inserted_at}) 
            |> Repo.all()
    
    sites_html = if Enum.empty?(sites) do
      """
      <div class="site-card" style="text-align: center; color: #6b7280;">
        <div class="site-name">No sites yet</div>
        <div class="site-url">Add your first site to start tracking analytics</div>
      </div>
      """
    else
      sites
      |> Enum.map(fn site ->
        date_str = Calendar.strftime(site.inserted_at, "%B %d, %Y")
        """
        <div class="site-card">
          <div class="site-name">#{site.domain}</div>
          <div class="site-url">Added #{date_str}</div>
          <div class="site-stats">
            <div class="stat">
              <div class="stat-number">0</div>
              <div class="stat-label">Visitors</div>
            </div>
            <div class="stat">
              <div class="stat-number">0</div>
              <div class="stat-label">Page views</div>
            </div>
            <div class="stat">
              <div class="stat-number">-%</div>
              <div class="stat-label">Bounce rate</div>
            </div>
          </div>
        </div>
        """
      end)
      |> Enum.join("\n")
    end
    
    # Show a working dashboard with real sites from database
    html(conn, """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Plausible Analytics - Dashboard</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #374151; }
        .header { background: white; border-bottom: 1px solid #e5e7eb; padding: 16px 24px; }
        .header-content { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 20px; font-weight: bold; color: #5850ec; }
        .user-info { color: #6b7280; }
        .container { max-width: 1200px; margin: 0 auto; padding: 24px; }
        .welcome { background: #10b981; color: white; padding: 16px; border-radius: 8px; margin-bottom: 24px; }
        .sites-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 32px; }
        .site-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border-left: 4px solid #5850ec; }
        .site-name { font-size: 18px; font-weight: 600; margin-bottom: 8px; color: #111827; }
        .site-url { color: #6b7280; font-size: 14px; }
        .site-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 16px; }
        .stat { text-align: center; }
        .stat-number { font-size: 24px; font-weight: bold; color: #5850ec; }
        .stat-label { font-size: 12px; color: #6b7280; text-transform: uppercase; }
        .add-site { background: #f9fafb; border: 2px dashed #d1d5db; border-radius: 8px; padding: 40px; text-align: center; }
        .add-btn { background: #5850ec; color: white; padding: 12px 24px; border-radius: 6px; text-decoration: none; display: inline-block; font-weight: 500; }
        .tracking-info { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-top: 24px; }
        .script-code { background: #1f2937; color: #f9fafb; padding: 12px; border-radius: 4px; font-family: monospace; margin: 8px 0; word-break: break-all; }
      </style>
    </head>
    <body>
      <div class="header">
        <div class="header-content">
          <div class="logo">� Plausible Analytics</div>
          <div class="user-info">Colin Differ • colin@propellernet.co.uk</div>
        </div>
      </div>
      
      <div class="container">
        <div class="welcome">
          🎉 <strong>Welcome to Plausible Analytics!</strong> Your privacy-friendly web analytics dashboard is ready.
        </div>
        
        <h2 style="margin-bottom: 16px;">Your Sites</h2>
        
        <div class="sites-grid">
          #{sites_html}
          
          <div class="add-site">
            <h3 style="margin-bottom: 8px;">Add New Site</h3>
            <p style="color: #6b7280; margin-bottom: 16px;">Start tracking a new website</p>
            <a href="/sites/new" class="add-btn" style="text-decoration: none; color: white;">+ Add Site</a>
          </div>
        </div>
        
        <div class="tracking-info">
          <h3 style="margin-bottom: 16px;">Quick Setup for New Sites</h3>
          <p style="margin-bottom: 12px;"><strong>Add this script to any website you want to track:</strong></p>
          <div class="script-code">&lt;script defer data-domain="yourdomain.com" src="#{conn.scheme}://#{conn.host}/js/script.js"&gt;&lt;/script&gt;</div>
          <p style="font-size: 14px; color: #6b7280; margin-top: 8px;">Replace "yourdomain.com" with your actual domain name.</p>
        </div>
      </div>
    </body>
    </html>
    """)
  end
end
