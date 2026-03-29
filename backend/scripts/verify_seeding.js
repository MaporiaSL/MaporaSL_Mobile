require('dotenv').config({ path: '../../.env' });
const mongoose = require('mongoose');
const User = require('../src/models/User');
const Travel = require('../src/models/Travel');

async function verifySeeding() {
  try {
    const mongoUri = process.env.MONGODB_URI || process.env.MONGODB_STRING;
    await mongoose.connect(mongoUri);
    
    const targetEmail = 'anuja.20231258@iit.ac.lk';
    const users = await User.find({ email: targetEmail });
    
    if (users.length === 0) {
      console.log(`❌ No users with email ${targetEmail} found.`);
      process.exit(1);
    }

    console.log(`👤 Found ${users.length} user record(s):`);
    users.forEach((u, i) => {
      console.log(`   [${i+1}] Name: ${u.name} | auth0Id: ${u.auth0Id}`);
    });

    const user = users[0];

    const travels = await Travel.find({ userId: user.auth0Id });
    console.log(`📊 Found ${travels.length} trips in 'travels' collection for this user.`);
    
    travels.forEach((t, i) => {
      console.log(`   [${i+1}] Title: "${t.title}" | Locations: ${t.locations.length} nodes | Start: ${t.startDate.toISOString()}`);
      t.locations.forEach(l => console.log(`      - ${l.name} (Day ${l.day})`));
    });

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

verifySeeding();
