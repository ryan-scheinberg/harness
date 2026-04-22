# TDD Reference

## Red-Green-Refactor

The loop is simple. The discipline is doing it one slice at a time.

```
RED:    Write one test that fails — describes a behavior you need
GREEN:  Write the minimum code to make it pass — nothing more
REFACTOR: Clean up while green — extract duplication, simplify interfaces
```

Repeat for each behavior. Each cycle builds on what you learned in the previous one.

### Vertical Slices, Not Horizontal Layers

Never write all tests first, then all implementation. That's horizontal slicing — it produces tests that describe imagined behavior instead of actual behavior.

```
Wrong:
  Write test1, test2, test3, test4, test5
  Then write impl1, impl2, impl3, impl4, impl5

Right:
  test1 → impl1
  test2 → impl2
  test3 → impl3
```

Each cycle responds to what you learned from the last one. Tests written in bulk test the shape of things, not what the system actually does.

---

## What Makes a Good Test

Good tests describe **what** the system does, not **how** it does it. They exercise real code paths through public interfaces. They survive refactors because they don't care about internal structure.

**Test behavior, not implementation:**

```python
# Good — tests observable outcome
def test_created_user_is_retrievable_by_id():
    user = create_user(name="Alice")
    found = get_user(user.id)
    assert found.name == "Alice"

# Bad — bypasses interface, couples to storage
def test_create_user_inserts_row():
    create_user(name="Alice")
    row = db.execute("SELECT * FROM users WHERE name = ?", ("Alice",)).fetchone()
    assert row is not None
```

**Warning signs of bad tests:**

- Test breaks when you refactor but behavior hasn't changed
- Test name describes HOW instead of WHAT
- Test mocks internal collaborators you control
- Test verifies call counts or call order
- Test accesses private methods or internal state

**Characteristics of good tests:**

- Uses public interface only
- One logical assertion per test
- Name reads like a specification: `test_user_can_checkout_with_valid_cart`
- Survives internal restructuring
- Fails when behavior actually breaks

---

## Mocking

Mock at **system boundaries** only — things you don't control:

- External APIs (payment providers, email services, third-party SDKs)
- Databases (prefer a test database when feasible)
- Time and randomness
- File system (when necessary)

**Don't mock your own code.** If you're mocking internal classes or modules, your design likely needs work — the boundaries are in the wrong place.

### Designing for Testability

**Inject dependencies instead of creating them:**

```python
# Testable — dependency is passed in
def process_payment(order, payment_client):
    return payment_client.charge(order.total)

# Hard to test — dependency is created internally
def process_payment(order):
    client = StripeClient(os.environ["STRIPE_KEY"])
    return client.charge(order.total)
```

**Prefer specific interfaces over generic fetchers:**

```python
# Good — each method is independently mockable
class UserAPI:
    def get_user(self, user_id: str) -> User: ...
    def create_order(self, data: dict) -> Order: ...

# Bad — mocking requires conditional logic
class GenericAPI:
    def fetch(self, endpoint: str, **kwargs): ...
```

**Return results instead of producing side effects:**

```python
# Testable — returns data you can assert on
def calculate_discount(cart) -> Discount:
    ...

# Hard to test — mutates state
def apply_discount(cart) -> None:
    cart.total -= discount
```

---

## Refactoring

Only refactor when tests are green. Never refactor while red.

**Common refactor targets after a TDD cycle:**

- **Duplication** — extract to a shared function or module
- **Long methods** — break into private helpers. Keep tests on the public interface.
- **Shallow modules** — combine or deepen. A module with a big interface and thin implementation is a sign of poor abstraction. Push complexity behind a simpler interface.
- **Feature envy** — logic that reaches into another module's data belongs in that module
- **Primitive obsession** — introduce value objects when raw types are being passed around with implicit meaning
- **Code the new work revealed** — new code often exposes existing problems. Note them, fix them if small, create tickets if large.

### Deep vs Shallow Modules

Prefer deep modules: small interface, substantial implementation.

```
Deep (good):
┌──────────────┐
│ Small API    │  ← Few methods, simple params
├──────────────┤
│              │
│ Complex      │  ← Lots of logic hidden inside
│ internals    │
│              │
└──────────────┘

Shallow (avoid):
┌──────────────────────────┐
│ Large API                │  ← Many methods, complex params
├──────────────────────────┤
│ Thin pass-through        │  ← Just delegates
└──────────────────────────┘
```

When designing or refactoring interfaces, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?
