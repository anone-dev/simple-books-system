import math
from flask import Blueprint, request, jsonify
from store import data

books_bp = Blueprint("books", __name__)


@books_bp.route("/books", methods=["GET"])
def list_books():
    """List books with pagination and optional type filter."""
    # Query params
    book_type = request.args.get("type")
    page = request.args.get("page", 1, type=int)
    page_size = request.args.get("pageSize", 5, type=int)

    # Clamp page_size
    page_size = max(1, min(page_size, 25))
    page = max(1, page)

    # Filter books
    all_books = list(data.books.values())
    if book_type in ("fiction", "non-fiction"):
        all_books = [b for b in all_books if b["type"] == book_type]

    # Pagination
    total_items = len(all_books)
    total_pages = math.ceil(total_items / page_size) if total_items > 0 else 1
    start = (page - 1) * page_size
    end = start + page_size
    page_books = all_books[start:end]

    # Return minimal fields for list
    books_response = [
        {
            "id": b["id"],
            "name": b["name"],
            "type": b["type"],
            "available": b["available"],
        }
        for b in page_books
    ]

    return jsonify({
        "books": books_response,
        "pagination": {
            "currentPage": page,
            "pageSize": page_size,
            "totalItems": total_items,
            "totalPages": total_pages,
        },
    }), 200


@books_bp.route("/books/<int:book_id>", methods=["GET"])
def get_book(book_id):
    """Get detailed information about a single book."""
    book = data.books.get(book_id)
    if book is None:
        return jsonify({"error": "Book not found."}), 404

    return jsonify(book), 200
