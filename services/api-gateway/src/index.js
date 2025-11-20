import express from 'express';
import fetch from 'node-fetch';

const app = express();
app.use(express.json());

const USERS_URL = process.env.USERS_URL;
const ORDERS_URL = process.env.ORDERS_URL;

app.get('/health', (req, res) => res.send('ok'));

app.get('/users', async (req, res) => {
  try {
    const response = await fetch(`${USERS_URL}/users`);
    const data = await response.json();
    res.json({ api: 'api-gateway', users: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/orders', async (req, res) => {
  try {
    const response = await fetch(`${ORDERS_URL}/orders`);
    const data = await response.json();
    res.json({ api: 'api-gateway', orders: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(process.env.PORT || 3000, () => {
  console.log('API Gateway running on port 3000');
});
