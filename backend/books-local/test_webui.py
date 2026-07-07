"""Verify Web UI serves correctly with Glassmorphism design."""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app

app = create_app()
c = app.test_client()

print("=== Web UI Verification ===\n")

r = c.get("/")
html = r.get_data(as_text=True)

checks = [
    ("Status 200", r.status_code == 200),
    ("Has glass-bg token", "glass-bg" in html),
    ("Has gradient background", "gradient-bg" in html or "bg-gradient" in html),
    ("Has backdrop-filter", "backdrop-filter" in html),
    ("Has decorative blobs", "bg-blob" in html),
    ("Has data-testid", "data-testid" in html),
    ("Has aria-label", "aria-label" in html),
    ("Has role=tab", 'role="tab"' in html),
    ("Has role=tabpanel", 'role="tabpanel"' in html),
    ("Has aria-live", "aria-live" in html),
    ("Has pagination section", "books-pagination" in html),
    ("Has auth section", "section-auth" in html),
    ("Has orders section", "section-orders" in html),
    ("Has API Docs link to /docs", "/docs" in html),
    ("Has filter chips", "books-filter-fiction" in html),
    ("Has register form", "register-input-name" in html),
    ("Has login form", "login-input-email" in html),
    ("Has reset server button", "server-reset-btn" in html),
]

all_pass = True
for name, result in checks:
    status = "PASS" if result else "FAIL"
    if not result:
        all_pass = False
    print(f"  {status}: {name}")

# Check openapi.json serves
r2 = c.get("/openapi.json")
oas_ok = r2.status_code == 200
print(f"  {'PASS' if oas_ok else 'FAIL'}: OpenAPI spec serves at /openapi.json (status {r2.status_code})")
if not oas_ok:
    all_pass = False

# Check /docs page serves
r3 = c.get("/docs")
docs_ok = r3.status_code == 200 and "swagger-ui" in r3.get_data(as_text=True)
print(f"  {'PASS' if docs_ok else 'FAIL'}: API docs page serves at /docs (status {r3.status_code})")
if not docs_ok:
    all_pass = False

print(f"\n=== {'ALL CHECKS PASSED' if all_pass else 'SOME CHECKS FAILED'} ===")
