# Testing Patterns

## General Principles

1. **Write tests for new functionality** — no untested features
2. **Test behavior, not implementation** — tests should survive refactoring
3. **Keep tests fast** — mock external services, use in-memory databases for unit tests
4. **One assertion per concept** — test one behavior per test function

## Python Testing

### Framework: pytest

```python
# tests/test_example.py
def test_user_creation():
    user = create_user(name="Test", email="test@example.com")
    assert user.name == "Test"
    assert user.email == "test@example.com"

def test_user_creation_rejects_invalid_email():
    with pytest.raises(ValueError):
        create_user(name="Test", email="not-an-email")
```

### Conventions
- Test files: `tests/test_<module>.py`
- Test functions: `test_<what_it_tests>`
- Fixtures for shared setup
- Use `pytest.mark.parametrize` for testing multiple inputs

## Node.js Testing

### Framework: vitest or jest

```javascript
// tests/example.test.js
describe('createUser', () => {
  it('creates a user with valid data', () => {
    const user = createUser({ name: 'Test', email: 'test@example.com' });
    expect(user.name).toBe('Test');
  });

  it('rejects invalid email', () => {
    expect(() => createUser({ name: 'Test', email: 'bad' })).toThrow();
  });
});
```

### Conventions
- Test files: `tests/<module>.test.js` or `__tests__/<module>.test.js`
- Use `describe` for grouping, `it` for individual tests
- Mock external APIs with `vi.mock()` or `jest.mock()`

## What to Test

| Priority | What | Example |
|----------|------|---------|
| High | Business logic | Calculations, validations, transformations |
| High | API endpoints | Request/response, error codes, auth |
| Medium | Data layer | Queries return expected results |
| Medium | Edge cases | Empty inputs, large datasets, boundary values |
| Low | UI components | Renders correctly, handles interactions |
