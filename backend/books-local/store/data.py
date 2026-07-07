"""In-memory data store for Simple Books System."""

import copy
from store.seed import get_initial_books

# Global in-memory stores
books = {}
clients = {}
orders = {}


def load_seed():
    """Load (or reload) books from seed data. Returns the books dict."""
    global books
    books = copy.deepcopy(get_initial_books())
    return books


def reset_all():
    """Full server reset: restore books, clear clients and orders."""
    global clients, orders
    load_seed()
    clients = {}
    orders = {}


# Initialize on module load
load_seed()
