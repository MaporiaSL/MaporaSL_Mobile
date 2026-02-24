const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
require('dotenv').config({ path: path.resolve(__dirname, '../../../.env') });

const Destination = require('../models/Destination');

// NEW PATH for real places dataset
const JSON_PATH = 'c:/Users/Asus/Downloads/sri_lanka_real_places_100.json';

async function importPlaces() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGODB_URI) {
            throw new Error('MONGODB_URI not found in environment');
        }
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB.');

        // Step 1: Clear existing system places
        console.log('Clearing existing system places for a clean swap...');
        const deleteResult = await Destination.deleteMany({ isSystemPlace: true });
        console.log(`Deleted ${deleteResult.deletedCount} old system places.`);

        console.log('Reading NEW JSON data from Downloads...');
        const rawData = fs.readFileSync(JSON_PATH, 'utf8');
        const places = JSON.parse(rawData); // New structure is a top-level array

        console.log(`Found ${places.length} real places. Starting import...`);

        let importedCount = 0;

        for (const place of places) {
            // Map JSON fields to Destination model
            const destination = new Destination({
                name: place.name,
                description: place.description,
                category: place.category, // Assuming categories in this JSON are already valid or tolerable
                province: place.province,
                districtId: place.district,
                latitude: place.latitude,
                longitude: place.longitude,
                address: place.address,
                googleMapsUrl: place.googleMapsUrl,
                rating: {
                    average: place.rating || 0,
                    reviewCount: place.reviewCount || 0
                },
                photos: place.photos || [],
                accessibility: {
                    season: place.accessibility?.season,
                    bestTime: place.accessibility?.bestTime, // If present
                    difficulty: place.accessibility?.difficulty,
                    estimatedDuration: place.accessibility?.duration, // Field was "duration" in JSON
                    entryFee: place.accessibility?.entryFee
                },
                tags: place.tags || [],
                isSystemPlace: true,
                visitCount: place.visitCount || 0,
                location: {
                    type: 'Point',
                    coordinates: [place.longitude, place.latitude]
                }
            });

            await destination.save();
            importedCount++;

            if (importedCount % 25 === 0) {
                console.log(`Imported ${importedCount} places...`);
            }
        }

        console.log(`Import Complete!`);
        console.log(`Summary: ${importedCount} real places imported.`);

    } catch (error) {
        console.error('Import failed:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected from MongoDB.');
    }
}

importPlaces();
