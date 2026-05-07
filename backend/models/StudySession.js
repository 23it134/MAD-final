const mongoose = require('mongoose');

const StudySessionSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  subjectId: { type: String, required: true },
  topicId: { type: String, required: true },
  dateTime: { type: Date, required: true },
  durationMinutes: { type: Number, required: true }
}, { timestamps: true });

module.exports = mongoose.model('StudySession', StudySessionSchema);
