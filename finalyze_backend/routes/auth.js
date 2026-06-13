const express = require('express');
const router = express.Router();
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { sendOtpEmail } = require('../services/emailService');
const { generateOtp, hashOtp, compareOtp, getOtpExpiry } = require('../utils/otpHelper');

const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_jwt_key';
const OTP_EXPIRY_MINUTES = parseInt(process.env.OTP_EXPIRY_MINUTES || '10', 10);

async function createAndSendOtp(user) {
    const otp = generateOtp();
    user.otpHash = await hashOtp(otp);
    user.otpExpiresAt = getOtpExpiry(OTP_EXPIRY_MINUTES);
    await user.save();

    try {
        await sendOtpEmail(user.email, otp, user.fullName);
    } catch (error) {
        console.error('[OTP] Email send failed:', error.message);
        throw error;
    }

    return otp;
}

router.post('/signup', async (req, res) => {
    try {
        const { fullName, email, password, userRole, region, organization } = req.body;

        let user = await User.findOne({ email });
        if (user) {
            if (user.emailVerified === false) {
                await createAndSendOtp(user);
                return res.status(200).json({
                    message: 'Account exists but is not verified. A new OTP has been sent to your email.',
                    email: user.email,
                    requiresVerification: true,
                });
            }
            return res.status(400).json({ message: 'User already exists with this email.' });
        }

        user = new User({
            fullName,
            email,
            password,
            userRole,
            region,
            organization,
            emailVerified: false,
        });

        await user.save();
        await createAndSendOtp(user);

        res.status(201).json({
            message: 'Registration successful. Please verify your email with the OTP sent.',
            email: user.email,
            requiresVerification: true,
        });
    } catch (error) {
        console.log('>>>> CLG SIGNUP ERROR LAYER:', error);
        res.status(500).json({ error: error.message });
    }
});

router.post('/verify-otp', async (req, res) => {
    try {
        const { email, otp } = req.body;

        if (!email || !otp) {
            return res.status(400).json({ message: 'Email and OTP are required.' });
        }

        const user = await User.findOne({ email: email.toLowerCase().trim() });
        if (!user) {
            return res.status(404).json({ message: 'No account found for this email.' });
        }

        if (user.emailVerified === true) {
            const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });
            return res.status(200).json({
                message: 'Email already verified.',
                token,
                userId: user._id,
            });
        }

        if (!user.otpHash || !user.otpExpiresAt) {
            return res.status(400).json({ message: 'No OTP found. Please request a new one.' });
        }

        if (new Date() > user.otpExpiresAt) {
            return res.status(400).json({ message: 'OTP has expired. Please request a new one.' });
        }

        const isValidOtp = await compareOtp(String(otp).trim(), user.otpHash);
        if (!isValidOtp) {
            return res.status(400).json({ message: 'Invalid OTP. Please try again.' });
        }

        user.emailVerified = true;
        user.otpHash = undefined;
        user.otpExpiresAt = undefined;
        await user.save();

        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });

        res.status(200).json({
            message: 'Email verified successfully.',
            token,
            userId: user._id,
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/resend-otp', async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Email is required.' });
        }

        const user = await User.findOne({ email: email.toLowerCase().trim() });
        if (!user) {
            return res.status(404).json({ message: 'No account found for this email.' });
        }

        if (user.emailVerified === true) {
            return res.status(400).json({ message: 'Email is already verified.' });
        }

        await createAndSendOtp(user);

        res.status(200).json({ message: 'A new OTP has been sent to your email.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/signin', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: 'Invalid email or password.' });
        }

        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid email or password.' });
        }

        if (user.emailVerified === false) {
            await createAndSendOtp(user);
            return res.status(403).json({
                message: 'Email not verified. A new OTP has been sent to your email.',
                requiresVerification: true,
                email: user.email,
            });
        }

        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });

        res.status(200).json({ message: 'Login successful', token, userId: user._id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
