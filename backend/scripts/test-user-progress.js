const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const User = require('../src/models/User');
const UserDistrictAssignment = require('../src/models/UserDistrictAssignment');
const PlaceVisit = require('../src/models/PlaceVisit');

const TARGET_EMAIL = 'anuja.20231258@iit.ac.lk';

async function setupTestProgress() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected.');

    const user = await User.findOne({ email: TARGET_EMAIL });
    if (!user) {
      console.log(`User with email ${TARGET_EMAIL} not found.`);
      return;
    }

    console.log(`Found user: ${user.name} (${user.auth0Id})`);

    // Find incomplete or active assignments
    const assignments = await UserDistrictAssignment.find({ userId: user.auth0Id });
    if (assignments.length === 0) {
      console.log('No district assignments found for this user. Please start an exploration in the app first.');
      return;
    }

    // Pick the most recent one or the first one that is not complete
    let targetAssignment = assignments.find(a => !a.unlockedAt) || assignments[0];
    
    console.log(`Setting up test state for district: ${targetAssignment.district}`);

    // We want the user to be 1 visit away from unlocking the district.
    const totalAssigned = targetAssignment.assignedLocationIds.length;
    if (totalAssigned < 1) {
      console.log('Assignment has no locations.');
      return;
    }

    // Set visited to all except the last one
    const newVisitedLocs = targetAssignment.assignedLocationIds.slice(0, totalAssigned - 1);
    
    targetAssignment.visitedLocationIds = newVisitedLocs;
    targetAssignment.visitedCount = newVisitedLocs.length;
    targetAssignment.unlockedAt = null;
    targetAssignment.visitedLocationProofs = []; // Clear proofs to be safe
    
    await targetAssignment.save();

    // Also remove this district from the User's unlocked arrays if it's there
    await User.updateOne(
      { _id: user._id },
      { 
        $pull: { 
          unlockedDistricts: targetAssignment.district,
          explorationUnlockedDistricts: targetAssignment.district 
        } 
      }
    );

    // Optional: Delete visits for the last location so it doesn't block visiting again
    const lastLocId = targetAssignment.assignedLocationIds[totalAssigned - 1];
    await PlaceVisit.deleteMany({ userId: user.auth0Id, placeId: lastLocId });

    console.log(`\n✅ Setup complete!`);
    console.log(`District ${targetAssignment.district} is now at ${newVisitedLocs.length}/${totalAssigned} visits.`);
    console.log(`\nTo test the unlock:`);
    console.log(`1. Open the app and log in as ${TARGET_EMAIL}`);
    console.log(`2. Go to the Exploration map.`);
    console.log(`3. You should see ${targetAssignment.district} needs 1 more visit.`);
    console.log(`4. Visit the remaining place to trigger the Shareable Card Celebration!`);

  } catch (e) {
    console.error('Error during setup:', e);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected.');
  }
}

setupTestProgress();
