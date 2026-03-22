const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
require('dotenv').config({ path: path.resolve(__dirname, '../../../.env') });

const Destination = require('../models/Destination');
const Place = require('../models/Place');
const { getPhotos } = require('../utils/photoLookupUtil');

// FIXED PATH relative to project root
const JSON_PATH = path.resolve(__dirname, '../../../project_resources/sri_lanka_real_places_100.json');

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
        const deleteDestResult = await Destination.deleteMany({ isSystemPlace: true });
        const deletePlaceResult = await Place.deleteMany({ source: 'system' });
        console.log(`Deleted ${deleteDestResult.deletedCount} old system destinations.`);
        console.log(`Deleted ${deletePlaceResult.deletedCount} old system places.`);

        console.log('Reading JSON data...');
        let rawData = fs.readFileSync(JSON_PATH, 'utf8');
        
        // Strip BOM or leading whitespace if present
        if (rawData.charCodeAt(0) === 0xFEFF) {
            rawData = rawData.slice(1);
        }
        rawData = rawData.trim();

        const places = JSON.parse(rawData);

        console.log(`Found ${places.length} potential places. Starting deduplicated import...`);

        // Deduplication tracking sets
        const seenLocations = new Set();
        const seenNames = new Set();
        let importedCount = 0;
        let skippedCount = 0;

        for (const place of places) {
            // 1. Normalize name (remove " Area X" suffix) to detect base duplicate
            const normalizedName = place.name.replace(/\sArea\s\d+$/, '').trim().toLowerCase();
            
            // 2. Normalize coordinates (4 decimal places ~11m precision)
            const lat = parseFloat(place.latitude).toFixed(4);
            const lng = parseFloat(place.longitude).toFixed(4);
            const locationKey = `${lat},${lng}`;

            // 3. Deduplication check: skip if we've seen this location or name base
            if (seenLocations.has(locationKey) || seenNames.has(normalizedName)) {
                skippedCount++;
                continue;
            }

            seenLocations.add(locationKey);
            seenNames.add(normalizedName);

            // 4. Safely map category (ensure it's in the Place model's enum)
            const allowedCategories = [
                'temple', 'beach', 'mountain', 'historical', 'wildlife', 'city', 
                'food', 'waterfall', 'garden', 'cultural', 'adventure', 'park', 
                'forest', 'museum', 'ruin', 'reserve', 'sanctuary', 'lake', 
                'tea-estate', 'other'
            ];
            const rawCategory = (place.category || 'other').toLowerCase();
            const safeCategory = allowedCategories.includes(rawCategory) ? rawCategory : 'other';

            // Mapping to Destination model
            const destination = new Destination({
                name: place.name,
                description: place.description || `Experience the beauty of ${place.name}.`,
                category: safeCategory,
                province: place.province,
                districtId: place.district, // Schema uses districtId
                latitude: place.latitude,
                longitude: place.longitude,
                address: place.address || `${place.name}, ${place.district}, Sri Lanka`,
                googleMapsUrl: place.googleMapsUrl,
                rating: {
                    average: place.rating || 0,
                    reviewCount: place.reviewCount || 0
                },
                photos: getPhotos(place.name, safeCategory),
                tags: place.tags || [],
                isSystemPlace: true,
                isActive: true,
                visitCount: place.visitCount || 0,
                location: {
                    type: 'Point',
                    coordinates: [place.longitude, place.latitude]
                }
            });

            // Mapping to Place model
            const placeDoc = new Place({
                name: place.name,
                description: place.description || `Experience the beauty of ${place.name}.`,
                category: safeCategory,
                province: place.province,
                district: place.district, // Schema uses district
                latitude: place.latitude,
                longitude: place.longitude,
                address: place.address || `${place.name}, ${place.district}, Sri Lanka`,
                googleMapsUrl: place.googleMapsUrl,
                rating: place.rating || 0,
                reviewCount: place.reviewCount || 0,
                photos: getPhotos(place.name, safeCategory),
                tags: place.tags || [],
                source: 'system',
                verified: true,
                isActive: true,
                visitCount: place.visitCount || 0,
                location: {
                    type: 'Point',
                    coordinates: [place.longitude, place.latitude]
                },
                accessibility: {
                    difficulty: (place.accessibility?.difficulty || 'easy').toLowerCase(),
                    estimatedDuration: place.accessibility?.duration || '1-2 hours',
                    entryFee: place.accessibility?.entryFee || 'Free'
                }
            });

            await destination.save();
            await placeDoc.save();
            importedCount++;

            if (importedCount % 20 === 0) {
                console.log(`Imported ${importedCount} unique places...`);
            }
        }

        console.log(`Import Complete!`);
        console.log(`Summary: ${importedCount} unique places imported. ${skippedCount} duplicates skipped.`);

    } catch (error) {
        console.error('Import failed:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected from MongoDB.');
    }
}

importPlaces();
