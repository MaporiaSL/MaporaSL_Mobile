const Destination = require('../models/Destination');

// Get all system places with pagination and filtering
exports.getPlaces = async (req, res) => {
    try {
        const {
            page = 1,
            limit = 20,
            search,
            category,
            province,
            district
        } = req.query;

        const query = { isSystemPlace: true };

        // Search by name (starts with) or description (contains)
        if (search) {
            query.$or = [
                { name: { $regex: `^${search}`, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } }
            ];
        }

        // Filters
        if (category) query.category = category;
        if (province) query.province = province;
        if (district) query.districtId = { $regex: district, $options: 'i' };

        console.log(`[PlacesAPI] Search: "${search || ''}", Query: ${JSON.stringify(query)}`);
        const places = await Destination.find(query)
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .sort({ visitCount: -1, rating: -1 });

        const total = await Destination.countDocuments(query);

        res.status(200).json({
            places,
            totalPages: Math.ceil(total / limit),
            currentPage: page,
            totalPlaces: total
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get single place by ID
exports.getPlaceById = async (req, res) => {
    try {
        const place = await Destination.findById(req.params.id);
        if (!place) {
            return res.status(404).json({ message: 'Place not found' });
        }
        res.status(200).json(place);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
