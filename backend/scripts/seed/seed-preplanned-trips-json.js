const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const mongoose = require('mongoose');
const PrePlannedTrip = require('../../src/models/PrePlannedTrip');

function buildTags(district, itineraryValues) {
    const text = `${district} ${itineraryValues.join(' ')}`.toLowerCase();
    const tags = new Set([district, 'Preplanned']);

    if (text.includes('beach') || text.includes('coast') || text.includes('whale')) {
        tags.add('Beach');
    }
    if (text.includes('temple') || text.includes('fort') || text.includes('museum')) {
        tags.add('Culture');
    }
    if (text.includes('hike') || text.includes('safari') || text.includes('climb') || text.includes('trek')) {
        tags.add('Adventure');
    }

    return Array.from(tags);
}

async function seedPreplannedTripsFromJson() {
    try {
        if (!process.env.MONGODB_URI) {
            throw new Error('MONGODB_URI is not defined in backend/.env');
        }

        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB connected');

        const jsonPath = path.resolve(__dirname, '../../../project_resources/preplannestrip.json');
        if (!fs.existsSync(jsonPath)) {
            throw new Error(`JSON file not found at ${jsonPath}`);
        }

        const rawData = fs.readFileSync(jsonPath, 'utf8');
        const data = JSON.parse(rawData);

        if (!Array.isArray(data.trips) || data.trips.length === 0) {
            throw new Error('Invalid JSON: expected non-empty "trips" array');
        }

        await PrePlannedTrip.deleteMany({});
        console.log('Cleared existing pre-planned trips');

        const tripsToInsert = data.trips.map((trip) => {
            const itineraryMap =
                trip.itinerary && typeof trip.itinerary === 'object' ? trip.itinerary : {};
            const itineraryValues = Object.values(itineraryMap).map((v) => String(v));

            return {
                title: trip.trip_name,
                district: trip.district,
                durationDays: Number(trip.duration_days) || 4,
                itinerary: itineraryMap,
                startingPoint: trip.district,
                description: `Explore ${trip.district} with the ${trip.trip_name} quest.`,
                difficulty: 'Moderate',
                xpReward: 300,
                tags: buildTags(trip.district, itineraryValues),
                placeIds: itineraryValues,
            };
        });

        const inserted = await PrePlannedTrip.insertMany(tripsToInsert);
        console.log(`Inserted ${inserted.length} pre-planned trips from JSON`);
    } catch (err) {
        console.error('Seed error:', err);
        process.exitCode = 1;
    } finally {
        await mongoose.disconnect();
        console.log('MongoDB disconnected');
    }
}

seedPreplannedTripsFromJson();
