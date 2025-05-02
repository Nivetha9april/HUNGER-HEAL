const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const cartRoutes = require('./routes/cart');
const donationRoutes = require('./routes/donations'); // 👈 new

const pool = require('./db');

const app = express();
const PORT = 5000;

app.use(cors());
app.use(bodyParser.json());

app.use('/submitCart', cartRoutes);
app.use('/donations', donationRoutes); // 👈 route added

pool.connect()
  .then(() => console.log('Connected to PostgreSQL'))
  .catch(err => console.error('PostgreSQL connection error:', err));

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
