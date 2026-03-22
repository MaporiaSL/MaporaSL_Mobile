const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, './.env') });

const Destination = require('./src/models/Destination');
const Place = require('./src/models/Place');

async function test() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected.');

        const destCount = await Destination.countDocuments({ isSystemPlace: true });
        const placeCount = await Place.countDocuments({ source: 'system' });

        console.log(`System Destinations: ${destCount}`);
        console.log(`System Places: ${placeCount}`);

        const samplePlace = await Place.findOne({ source: 'system', photos: { $exists: true, $not: { $size: 0 } } });
        if (samplePlace) {
            console.log('Found a place with photos!');
            console.log(`Name: ${samplePlace.name}`);
            console.log(`Photos: ${samplePlace.photos.length}`);
            console.log(`Description: ${samplePlace.description ? 'Yes' : 'No'}`);
        } else {
            console.log('No places with photos found yet.');
        }

    } catch (e) {
        console.error('Test failed:', e);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected.');
    }
}

test();
