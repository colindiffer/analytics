# Plausible Analytics Deployment Project Status

## 🎯 Project Overview
**Goal**: Deploy Plausible Analytics Community Edition to `analytics.propellernet.co.uk` using Google Cloud and Cloudflare DNS

**Status**: ❌ **INCOMPLETE** - Server errors preventing dashboard access despite successful deployment

---

## ✅ Completed Tasks

### 1. Initial Setup & Environment
- **Local Development**: Successfully set up Plausible Analytics CE locally
- **ClickHouse Removal**: Disabled ClickHouse dependencies in `lib/plausible/application.ex`
  - Commented out: `IngestRepo`, `AsyncInsertRepo`, `ImportDeletionRepo`
  - Removed: `Plausible.Ingestion.Counters`
- **Local Testing**: Confirmed application runs locally without ClickHouse

### 2. Google Cloud Infrastructure
- **Project Setup**: Created `propellernet-analytics` GCP project
- **Artifact Registry**: Created `plausible-repo` container registry
- **Cloud SQL**: Deployed PostgreSQL instance with connection details:
  - Instance: `plausible-db`
  - Database: `plausible`
  - User: `plausible`
  - Connection: `propellernet-analytics:us-central1:plausible-db`
- **Cloud Run**: Deployed service at `https://plausible-924608013587.us-central1.run.app`

### 3. Database Schema
- **Complete Schema**: Successfully migrated all required tables via Cloud Run
- **Tables Created**: users, teams, sites, site_memberships, shared_links, goals, custom_events, etc.
- **Oban Jobs**: Background job processing tables configured
- **Indexes**: All necessary database indexes in place

### 4. DNS & SSL Configuration
- **Cloudflare DNS**: CNAME record configured
  - `analytics.propellernet.co.uk` → `ghs.googlehosted.com`
- **SSL Certificate**: Google-managed SSL certificate provisioning
- **Domain Mapping**: Custom domain successfully mapped to Cloud Run service

### 5. Authentication Bypass (For Testing)
- **Router Pipeline**: Modified `lib/plausible_web/router.ex`
  - Disabled `PlausibleWeb.AuthPlug` in `:browser` pipeline
  - Disabled `PlausibleWeb.FirstLaunchPlug` in `:browser` pipeline
  - Disabled `RequireAccountPlug` in sites LiveView scope
- **Page Controller**: Modified `lib/plausible_web/controllers/page_controller.ex`
  - Disabled `RequireLoggedOutPlug`
  - Changed index action to redirect to `/sites` dashboard
- **Sites LiveView**: Modified `lib/plausible_web/live/sites.ex`
  - Added nil handling for `current_user` and `current_team`
  - Modified `mount/3` to handle missing authentication
  - Updated `handle_params/3` with nil-safe logic
  - Modified `load_sites/1` to return empty results when no user
  - Fixed template rendering for missing team context

### 6. Docker & Deployment
- **Dockerfile**: Production-ready containerization
- **Environment Variables**: Cloud Run configured with:
  - `DATABASE_URL`: PostgreSQL connection string
  - `SECRET_KEY_BASE`: Generated secret key
  - `BASE_URL`: Custom domain URL
- **Build Process**: Automated Docker builds and pushes to Artifact Registry
- **Deployment**: Multiple successful deployments to Cloud Run

---

## ❌ Current Issues

### 1. Server Error on Dashboard Access
**Problem**: Accessing `/sites` results in server error page
**Error Details**: Unknown - need to check Cloud Run logs
**Impact**: Cannot access dashboard functionality despite successful deployment

### 2. Authentication System Conflicts
**Problem**: Even with authentication disabled, application may still expect user context
**Files Affected**: 
- `lib/plausible_web/live/sites.ex` - may have remaining user dependencies
- Other LiveView modules may also require user context
**Impact**: Prevents dashboard from loading properly

### 3. Missing Development Features
**Problem**: Application deployed in production mode without development aids
**Missing**: Debug logging, error details, development-friendly error pages
**Impact**: Difficult to diagnose runtime issues

---

## 🔧 Immediate Next Steps

### 1. Investigate Server Error
**Priority**: HIGH
**Actions**:
```bash
# Check Cloud Run logs
gcloud run services logs read plausible --region=us-central1 --limit=50

# Examine specific error details
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=plausible" --limit=20 --format=json
```

### 2. Fix Sites LiveView Dependencies
**Priority**: HIGH
**Files to Check**:
- `lib/plausible_web/live/sites.ex` - verify all user references handled
- `lib/plausible/teams/invitations.ex` - check if `all/1` function can handle nil
- `lib/plausible/sites.ex` - verify `list_with_invitations/3` with nil user

### 3. Add Debugging Capabilities
**Priority**: MEDIUM
**Actions**:
- Enable debug logging in production temporarily
- Add error handling in LiveView mount functions
- Consider deploying with development environment first

### 4. Verify Database Connectivity
**Priority**: MEDIUM
**Actions**:
- Test database connection from Cloud Run
- Verify all required environment variables are set
- Check Cloud SQL proxy configuration

---

## 🚀 Future Enhancements (After Core Issues Resolved)

### 1. Authentication Implementation
**Priority**: LOW (after testing complete)
**Tasks**:
- Re-enable authentication system
- Set up user registration/login
- Configure email verification
- Implement password recovery

### 2. ClickHouse Integration (Optional)
**Priority**: LOW
**Tasks**:
- Set up ClickHouse Cloud instance
- Re-enable ClickHouse repositories in application.ex
- Configure ClickHouse connection string
- Migrate to full analytics capabilities

### 3. Monitoring & Observability
**Priority**: MEDIUM
**Tasks**:
- Set up Google Cloud Monitoring
- Configure alerting for service health
- Add application performance monitoring
- Set up log aggregation and analysis

### 4. Security Hardening
**Priority**: HIGH (before production use)
**Tasks**:
- Re-enable and configure authentication
- Set up proper RBAC (Role-Based Access Control)
- Configure HTTPS-only policies
- Implement rate limiting
- Add CSRF protection

### 5. Backup & Recovery
**Priority**: MEDIUM
**Tasks**:
- Set up automated database backups
- Configure point-in-time recovery
- Test restore procedures
- Document disaster recovery process

---

## 📁 Key Files Modified

### Core Application
- `lib/plausible/application.ex` - ClickHouse removal
- `lib/plausible_web/router.ex` - Authentication bypass
- `lib/plausible_web/controllers/page_controller.ex` - Landing page redirect
- `lib/plausible_web/live/sites.ex` - User context handling

### Infrastructure
- `Dockerfile` - Production containerization
- `.dockerignore` - Build optimization
- Environment variables via Cloud Run configuration

### Configuration
- Database migrations - All tables created successfully
- Environment variables - Production configuration

---

## 🔍 Debugging Commands

### Check Application Status
```bash
# View recent logs
gcloud run services logs read plausible --region=us-central1 --limit=20

# Check service status
gcloud run services describe plausible --region=us-central1

# Test database connectivity
gcloud sql connect plausible-db --user=plausible --database=plausible
```

### Test Local Development
```bash
# Run locally with database
docker-compose up -d
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
```

### Rebuild and Deploy
```bash
# Build new image
docker build -t us-central1-docker.pkg.dev/propellernet-analytics/plausible-repo/plausible:latest .

# Push to registry
docker push us-central1-docker.pkg.dev/propellernet-analytics/plausible-repo/plausible:latest

# Deploy to Cloud Run
gcloud run deploy plausible --image us-central1-docker.pkg.dev/propellernet-analytics/plausible-repo/plausible:latest --region us-central1 --allow-unauthenticated
```

---

## 📞 Support Resources

### Google Cloud Documentation
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)

### Plausible Analytics
- [Self-Hosting Guide](https://plausible.io/docs/self-hosting)
- [Community Edition GitHub](https://github.com/plausible/analytics)
- [Configuration Options](https://plausible.io/docs/self-hosting-configuration)

### Elixir/Phoenix
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/)
- [Elixir Documentation](https://elixir-lang.org/docs.html)

---

**Last Updated**: October 8, 2025
**Next Review**: After resolving current server errors
**Contact**: Continue debugging with GitHub Copilot for technical assistance