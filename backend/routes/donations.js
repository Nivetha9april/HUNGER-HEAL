const express = require('express');
const router = express.Router();
const pool = require('../db'); // Adjust this as needed

// POST /donations - Add new donation
router.post('/', async (req, res) => {
  const { donorId, foodName, foodType, expiryDate, quantity, pickupLocation } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO donation (donor_id, food_name, food_type, expiry_date, quantity, pickup_location, donation_date) VALUES ($1, $2, $3, $4, $5, $6, NOW()) RETURNING *',
      [donorId, foodName, foodType, expiryDate, quantity, pickupLocation]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error inserting donation:', err);
    res.status(500).json({ error: 'Failed to add donation' });
  }
});

// GET /donations - Get all donations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM donation ORDER BY donation_date DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching all donations:', err);
    res.status(500).json({ error: 'Failed to fetch all donations' });
  }
});

// GET /donations/:donorId - Get donations by donor
router.get('/:donorId', async (req, res) => {
  const { donorId } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM donation WHERE donor_id = $1 ORDER BY donation_date DESC',
      [donorId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching donations by donor:', err);
    res.status(500).json({ error: 'Failed to fetch donations' });
  }
});

module.exports = router;
