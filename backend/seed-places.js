require('dotenv').config({ path: './.env' });
const mongoose = require('mongoose');
const Destination = require('./src/models/Destination');
const fs = require('fs');
const path = require('path');

// Connect to MongoDB
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB Connected');
    } catch (err) {
        console.error('Failed to connect to MongoDB:', err.message);
        process.exit(1);
    }
};

const importData = async () => {
    await connectDB();

    try {
        // Read the JSON file
        const dataPath = path.join(__dirname, '..', 'project_resorces', 'sri_lanka_real_places_100.json');

        if (!fs.existsSync(dataPath)) {
            console.error(`Error: File not found at ${dataPath}`);
            process.exit(1);
        }

        const fileContent = fs.readFileSync(dataPath, 'utf-8');
        const jsonData = JSON.parse(fileContent);
        // Handle root array or key
        const places = Array.isArray(jsonData) ? jsonData : jsonData.places;

        if (!Array.isArray(places)) {
            console.error('Error: Places data is not an array');
            process.exit(1);
        }

        console.log(`Found ${places.length} places to import...`);

        let count = 0;
        for (const place of places) {
            // Check if place already exists by name to avoid duplicates
            const exists = await Destination.findOne({ name: place.name, isSystemPlace: true });
            if (exists) {
                // console.log(`Skipping duplicate: ${place.name}`);
                continue;
            }

            await Destination.create({
                name: place.name,
                description: place.description,
                notes: place.description,
                category: place.category,
                province: place.province,
                districtId: place.district,
                address: place.address,
                latitude: place.latitude,
                longitude: place.longitude,
                location: {
                    type: 'Point',
                    coordinates: [place.longitude, place.latitude]
                },
                googleMapsUrl: place.googleMapsUrl,
                accessibility: place.accessibility,
                rating: {
                    average: place.rating,
                    reviewCount: place.reviewCount
                },
                photos: place.photos,
                tags: place.tags,
                isSystemPlace: true,
                visited: false,
                visitCount: place.visitCount || 0
            });
            count++;
        }

        console.log(`Successfully imported ${count} places.`);
        process.exit(0);
    } catch (error) {
        console.error('Error with data import:', error);
        process.exit(1);
    }
};

importData();
