const express = require('express');
const app = express();

app.use(express.json());

app.get('/health', (req, res) => res.send('ok'));

app.get('/orders', (req, res) => {
  res.json([
    { id: 101, item: "Laptop", qty: 1 },
    { id: 102, item: "Phone", qty: 2 }
  ]);
});

app.listen(process.env.PORT || 3002, () =>
  console.log('orders running')
);
