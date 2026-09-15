function add(a, b) {
  return a + b;
}

function greet(name) {
  if (!name) throw new Error("name is required");
  return `Hello, ${name}!`;
}

module.exports = { add, greet };
