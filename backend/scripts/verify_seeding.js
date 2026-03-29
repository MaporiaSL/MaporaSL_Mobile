require('dotenv').config({ path: '../../.env' });
const mongoose = require('mongoose');
const User = require('../src/models/User');
const Travel = require('../src/models/Travel');
const PlaceVisit = require('../src/models/PlaceVisit');

async function check() {
  try {
    const mongoUri = process.env.MONGODB_URI || process.env.MONGODB_STRING;
    console.log(`🔌 Connecting to ${mongoUri ? 'database' : 'NULL'}...`);
    await mongoose.connect(mongoUri);
    
    const targetEmail = 'anuja.20231258@iit.ac.lk';
    const user = await User.findOne({ email: targetEmail });
    
    if (!user) {
      console.log(`❌ User with email ${targetEmail} NOT FOUND in DB!`);
      process.exit(1);
    }
    
    const trips = await Travel.countDocuments({ userId: user.auth0Id });
    const visits = await PlaceVisit.countDocuments({ userId: user.auth0Id });
    
    console.log(JSON.stringify({ 
      email: user.email, 
      auth0Id: user.auth0Id, 
      trips, 
      visits, 
      achievements: user.achievements.length 
    }, null, 2));
    
    const latestTrips = await Travel.find({ userId: user.auth0Id }).limit(5).select('title status');
    console.log('Latest 5 trips:', latestTrips);
    
    process.exit(0);
  } catch (e) {
    console.error('❌ Verification Error:', e);
    process.exit(1);
  }
}
check();
