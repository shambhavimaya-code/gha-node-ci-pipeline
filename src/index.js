function add(a, b) {
  return a + b;
}

function greet(name) {
  if (!name) throw new Error("name is required");
  return `Hello, ${name}!`;
}

module.exports = { add, greet };

const http = require("http");

function add(a, b) {
  return a + b;
}

function greet(name) {
  if (!name) throw new Error("name is required");
  return `Hello, ${name}!`;
}

// Only start the server if this file is run directly (not when required by tests)
if (require.main === module) {
  const port = process.env.PORT || 80;
  const server = http.createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(greet("from GitHub Actions"));
  });
  server.listen(port, () => console.log(`Listening on port ${port}`));
}

module.exports = { add, greet };
