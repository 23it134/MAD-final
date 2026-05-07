require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const Subject = require('./models/Subject');
const StudySession = require('./models/StudySession');

// Subjects Routes
app.get('/api/subjects', async (req, res) => {
  try {
    const subjects = await Subject.find();
    res.json(subjects);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/subjects', async (req, res) => {
  try {
    const subject = new Subject(req.body);
    await subject.save();
    res.status(201).json(subject);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/subjects/:id', async (req, res) => {
  try {
    const subject = await Subject.findOneAndUpdate({ id: req.params.id }, req.body, { new: true });
    res.json(subject);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/subjects/:id', async (req, res) => {
  try {
    await Subject.findOneAndDelete({ id: req.params.id });
    res.json({ message: 'Deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Sessions Routes
app.get('/api/sessions', async (req, res) => {
  try {
    const sessions = await StudySession.find();
    res.json(sessions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/sessions', async (req, res) => {
  try {
    const session = new StudySession(req.body);
    await session.save();
    res.status(201).json(session);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/sessions/:id', async (req, res) => {
  try {
    await StudySession.findOneAndDelete({ id: req.params.id });
    res.json({ message: 'Deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Sync Endpoint
app.post('/api/sync', async (req, res) => {
  try {
    const { subjects, sessions } = req.body;

    if (subjects && Array.isArray(subjects)) {
      await Subject.deleteMany({});
      if (subjects.length > 0) await Subject.insertMany(subjects);
    }
    
    if (sessions && Array.isArray(sessions)) {
      await StudySession.deleteMany({});
      if (sessions.length > 0) await StudySession.insertMany(sessions);
    }

    res.json({ message: 'Sync successful' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/studyplanner';

mongoose.connect(MONGO_URI).then(() => {
  console.log('Connected to MongoDB');
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}).catch(err => {
  console.error('MongoDB connection error:', err.message);
});
