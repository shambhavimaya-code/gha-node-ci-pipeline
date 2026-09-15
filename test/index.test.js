const { add, greet } = require("../src/index");

test("add sums two numbers", () => {
  expect(add(2, 3)).toBe(5);
});

test("greet returns a greeting", () => {
  expect(greet("World")).toBe("Hello, World!");
});

test("greet throws when name is missing", () => {
  expect(() => greet()).toThrow("name is required");
});
