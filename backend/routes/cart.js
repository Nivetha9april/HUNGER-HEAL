// routes/cart.js

const express = require("express");
const router = express.Router();
const pool = require("../db");

router.post("/", async (req, res) => {
  const {
    foodName,
    foodType,
    quantity,
    expiryDate,
    pickupLocation,
    donationDate,
    serviceType,
    totalPrice
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO cart_orders 
        (food_name, food_type, quantity, expiry_date, pickup_location, donation_date, service_type, price) 
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [foodName, foodType, quantity, expiryDate, pickupLocation, donationDate, serviceType, totalPrice]
    );

    res.status(201).json(result.rows[0]); // success response
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Failed to insert cart order" });
  }
});

module.exports = router;
