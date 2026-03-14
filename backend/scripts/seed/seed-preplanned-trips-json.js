const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, './.env') });
const mongoose = require('mongoose');
const PrePlannedTrip = require('./src/models/PrePlannedTrip');

async function seedPreplannedTripsFromJson() {
    try {
        // Connect to MongoDB
        if (!process.env.MONGODB_URI) {
            throw new Error('MONGODB_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connected');

        // Read JSON file
        const jsonPath = path.resolve(__dirname, '../project_resorces/preplannestrip.json');
        if (!fs.existsSync(jsonPath)) {
            throw new Error(`JSON file not found at ${jsonPath}`);
        }
        const rawData = fs.readFileSync(jsonPath, 'utf8');
        const data = JSON.parse(rawData);

        if (!data.trips || !Array.isArray(data.trips)) {
            throw new Error('Invalid JSON structure: "trips" array not found');
        }

        // Clear existing pre-planned trips
        await PrePlannedTrip.deleteMany({});
        console.log('Cleared existing pre-planned trips');

        // Map JSON data to Model
        const tripsToInsert = data.trips.map(trip => ({
            title: trip.trip_name,
            district: trip.district,
            durationDays: trip.duration_days,
            itinerary: trip.itinerary,
            startingPoint: trip.district, // Using district as starting point by default
            description: `Explore the highlights of ${trip.district} with this curated "${trip.trip_name}" 4-day journey.`,
            difficulty: 'Moderate',
            xpReward: 300,
            tags: [trip.district, 'Culture', 'Adventure'],
            placeIds: Object.values(trip.itinerary) // Storing the text as placeIds for now as placeholders
        }));

        // Insert into database
        const inserted = await PrePlannedTrip.insertMany(tripsToInsert);
        console.log(`Successfully inserted ${inserted.length} pre-planned trips from JSON.`);

        await mongoose.disconnect();
        console.log('Done!');
    } catch (err) {
        console.error('Seed error:', err);
        process.exit(1);
    }
}

seedPreplannedTripsFromJson();
