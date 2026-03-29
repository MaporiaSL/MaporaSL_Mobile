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

// List travels for current user with aggregated destination counts
async function listTravels(req, res) {
  try {
    const { sortBy = 'startDate', limit = 20, skip = 0 } = req.query;

    const total = await Travel.countDocuments({ userId: req.userId });

    const sortOptions = {
      startDate: { startDate: 1 },
      createdAt: { createdAt: -1 }
    };

    const sortOrder = sortOptions[sortBy] || { startDate: 1 };

    // Use aggregation to count destinations and visited ones
    const travels = await Travel.aggregate([
      { $match: { userId: req.userId } },
      { $sort: sortOrder },
      { $skip: Number(skip) },
      { $limit: Number(limit) },
      {
        $lookup: {
          from: 'destinations',
          localField: '_id',
          foreignField: 'travelId',
          as: 'destinations'
        }
      },
      {
        $addFields: {
          destinationCount: { $size: '$destinations' },
          visitedCount: {
            $size: {
              $filter: {
                input: '$destinations',
                as: 'dest',
                cond: { $eq: ['$$dest.visited', true] }
              }
            }
          }
        }
      },
      {
        $project: {
          destinations: 0 // Don't return all destination objects to keep response light
        }
      }
    ]);

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
