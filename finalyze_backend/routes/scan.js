const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const Scan = require('../models/Scan');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); 
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}_${path.basename(file.originalname)}`);
    }
});

const upload = multer({ storage: storage });

router.get('/history/:userId', async (req, res) => {
    try {
        const historyLogs = await Scan.find({ userId: req.params.userId }).sort({ createdAt: -1 });
        res.status(200).json(historyLogs);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/save-scan', upload.single('fishImage'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: "Fish image file payload is required." });
        }

        const { userId, fishName, category, percentage, area, scanDate, scanTime } = req.body;

        const newScan = new Scan({
            userId,
            imagePath: req.file.path, 
            fishName,
            category,
            percentage: parseFloat(percentage),
            area,
            scanDate,
            scanTime
        });

        await newScan.save();
        res.status(201).json({ message: "Scan metrics saved successfully to history profile!", scan: newScan });
    } catch (error) {
        console.error("Save Scan Backend Failure:", error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;