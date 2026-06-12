const express = require('express');
const router = express.Router();
const User = require('../models/User');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || "your_super_secret_jwt_key";

router.post('/signup', async (req, res) => {
    try {
        const { fullName, email, password, userRole, region, organization } = req.body;

        let user = await User.findOne({ email });
        if (user) {
            return res.status(400).json({ message: "User already exists with this email." });
        }

        user = new User({ 
            fullName, 
            email, 
            password, 
            userRole, 
            region, 
            organization 
        });
        
        await user.save();

const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });
        res.status(201).json({ message: "User registered successfully", token, userId: user._id });
    } catch (error) {
      console.log(">>>> CLG SIGNUP ERROR LAYER:", error);
        res.status(500).json({ error: error.message });
    }
});

router.post('/signin', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: "Invalid email or password." });
        }

        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid email or password." });
        }

        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });

        res.status(200).json({ message: "Login successful", token, userId: user._id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;