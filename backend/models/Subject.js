const mongoose = require('mongoose');

const TopicSchema = new mongoose.Schema({
  id: { type: String, required: true },
  name: { type: String, required: true },
  estimatedMinutes: { type: Number, required: true },
  status: { type: String, default: 'Not Started' }
});

const SubjectSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  topics: [TopicSchema]
}, { timestamps: true });

module.exports = mongoose.model('Subject', SubjectSchema);
