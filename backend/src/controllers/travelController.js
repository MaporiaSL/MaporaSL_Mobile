const Travel = require('../models/Travel');
const Destination = require('../models/Destination');

// Create travel
async function createTravel(req, res) {
  try {
    const { title, description, startDate, endDate, locations } = req.body;

    const travel = new Travel({
      userId: req.userId,
      title,
      description,
      startDate,
      endDate,
      locations: locations || []
    });

    await travel.save();

    res.status(201).json({
      message: 'Travel created successfully',
      travel
    });
  } catch (error) {
    console.error('Create travel error:', error);
    res.status(500).json({ error: 'Failed to create travel' });
  }
}

// List travels for current user
async function listTravels(req, res) {
  try {
    const { sortBy = 'startDate', limit = 20, skip = 0 } = req.query;

    const query = Travel.find({ userId: req.userId });
    const total = await Travel.countDocuments({ userId: req.userId });

    const sortOptions = {
      startDate: { startDate: 1 },
      createdAt: { createdAt: -1 }
    };

    if (sortOptions[sortBy]) {
      query.sort(sortOptions[sortBy]);
    }

    const travels = await query.limit(Number(limit)).skip(Number(skip));

    res.json({
      travels,
      total,
      limit: Number(limit),
      skip: Number(skip)
    });
  } catch (error) {
    console.error('List travels error:', error);
    res.status(500).json({ error: 'Failed to fetch travels' });
  }
}

// Get single travel
async function getSingleTravel(req, res) {
  try {
    const { travelId } = req.params;

    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });

    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    res.json({ travel });
  } catch (error) {
    console.error('Get travel error:', error);
    res.status(500).json({ error: 'Failed to fetch travel' });
  }
}

// Update travel
async function updateTravel(req, res) {
  try {
    const { travelId } = req.params;
    const { title, description, startDate, endDate, locations } = req.body;

    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });

    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    // Update fields
    if (title !== undefined) travel.title = title;
    if (description !== undefined) travel.description = description;
    if (startDate !== undefined) travel.startDate = startDate;
    if (endDate !== undefined) travel.endDate = endDate;
    if (locations !== undefined) travel.locations = locations;

    await travel.save();

    res.json({
      message: 'Travel updated successfully',
      travel
    });
  } catch (error) {
    console.error('Update travel error:', error);
    res.status(500).json({ error: 'Failed to update travel' });
  }
}

// Delete travel (cascade delete destinations)
async function deleteTravel(req, res) {
  try {
    const { travelId } = req.params;

    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });

    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    // Delete all destinations for this travel
    await Destination.deleteMany({ travelId });

    // Delete travel
    await Travel.deleteOne({ _id: travelId });

    res.json({ message: 'Travel deleted successfully' });
  } catch (error) {
    console.error('Delete travel error:', error);
    res.status(500).json({ error: 'Failed to delete travel' });
  }
}

module.exports = {
  createTravel,
  listTravels,
  getSingleTravel,
  updateTravel,
  deleteTravel
};
