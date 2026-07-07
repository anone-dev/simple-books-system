"""Quick smoke test for all API endpoints."""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app

app = create_app()
c = app.test_client()

print("=== API Server Smoke Test ===\n")

# 1. Status
r = c.get("/status")
print(f"1. GET /status: {r.status_code} {r.get_json()}")
assert r.status_code == 200

# 2. Register
r = c.post("/api-clients", json={"clientName": "QA", "clientEmail": "qa@test.com", "clientPassword": "pass123"})
print(f"2. POST /api-clients (register): {r.status_code}")
assert r.status_code == 201
token = r.get_json()["accessToken"]
print(f"   token: {token[:12]}...")

# 3. Duplicate register
r = c.post("/api-clients", json={"clientName": "QA", "clientEmail": "qa@test.com", "clientPassword": "pass123"})
print(f"3. POST /api-clients (duplicate): {r.status_code}")
assert r.status_code == 409

# 4. Login success
r = c.post("/api-clients/login", json={"clientEmail": "qa@test.com", "clientPassword": "pass123"})
print(f"4. POST /api-clients/login (correct): {r.status_code} token_match={r.get_json()['accessToken'] == token}")
assert r.status_code == 200

# 5. Login wrong password
r = c.post("/api-clients/login", json={"clientEmail": "qa@test.com", "clientPassword": "wrong"})
print(f"5. POST /api-clients/login (wrong pw): {r.status_code}")
assert r.status_code == 401

# 6. Books default pagination
r = c.get("/books")
j = r.get_json()
print(f"6. GET /books: {r.status_code} books={len(j['books'])} total={j['pagination']['totalItems']} pages={j['pagination']['totalPages']}")
assert r.status_code == 200
assert len(j["books"]) == 5
assert j["pagination"]["totalItems"] == 25
assert j["pagination"]["totalPages"] == 5

# 7. Books page 2
r = c.get("/books?page=2")
j = r.get_json()
print(f"7. GET /books?page=2: currentPage={j['pagination']['currentPage']} books={len(j['books'])}")
assert j["pagination"]["currentPage"] == 2

# 8. Books filter fiction
r = c.get("/books?type=fiction")
j = r.get_json()
fiction_count = j["pagination"]["totalItems"]
print(f"8. GET /books?type=fiction: totalItems={fiction_count}")
assert all(b["type"] == "fiction" for b in j["books"])

# 9. Book detail
r = c.get("/books/1")
print(f"9. GET /books/1: {r.status_code} has_author={'author' in r.get_json()}")
assert r.status_code == 200
assert "author" in r.get_json()

# 10. Book not found
r = c.get("/books/999")
print(f"10. GET /books/999: {r.status_code}")
assert r.status_code == 404

# 11. Create order
headers = {"Authorization": f"Bearer {token}"}
r = c.post("/orders", json={"bookId": 1, "customerName": "John"}, headers=headers)
print(f"11. POST /orders: {r.status_code}")
assert r.status_code == 201
order_id = r.get_json()["orderId"]

# 12. Create order no auth
r = c.post("/orders", json={"bookId": 1, "customerName": "NoAuth"})
print(f"12. POST /orders (no auth): {r.status_code}")
assert r.status_code == 401

# 13. Create order Book ID 3 (out of stock but bug allows it)
r = c.post("/orders", json={"bookId": 3, "customerName": "BugHunter"}, headers=headers)
print(f"13. POST /orders bookId=3 (0 stock, bug): {r.status_code}")
assert r.status_code == 201

# 14. List orders
r = c.get("/orders", headers=headers)
print(f"14. GET /orders: {r.status_code} count={len(r.get_json())}")
assert r.status_code == 200
assert len(r.get_json()) == 2

# 15. Get single order
r = c.get(f"/orders/{order_id}", headers=headers)
print(f"15. GET /orders/{order_id}: {r.status_code}")
assert r.status_code == 200

# 16. Update order
r = c.patch(f"/orders/{order_id}", json={"customerName": "Jane"}, headers=headers)
print(f"16. PATCH /orders/{order_id}: {r.status_code}")
assert r.status_code == 204

# 17. Delete order
r = c.delete(f"/orders/{order_id}", headers=headers)
print(f"17. DELETE /orders/{order_id}: {r.status_code}")
assert r.status_code == 204

# 18. Stock reset
r = c.post("/stock/reset")
print(f"18. POST /stock/reset: {r.status_code}")
assert r.status_code == 200

# 19. Server reset
r = c.post("/server/reset")
print(f"19. POST /server/reset: {r.status_code}")
assert r.status_code == 200

# 20. Token invalid after server reset
r = c.get("/orders", headers=headers)
print(f"20. GET /orders (after reset): {r.status_code}")
assert r.status_code == 401

print("\n=== ALL 20 TESTS PASSED ===")
