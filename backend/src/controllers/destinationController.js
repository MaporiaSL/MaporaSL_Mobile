const Destination = require('../models/Destination');
const Travel = require('../models/Travel');

// Create destination
async function createDestination(req, res) {
  try {
    const { travelId } = req.params;
    const { name, latitude, longitude, notes, visited } = req.body;

    // Verify travel exists and belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    const destination = new Destination({
      userId: req.userId,
      travelId,
      name,
      latitude,
      longitude,
      notes,
      visited: visited || false
    });

    await destination.save();

    res.status(201).json({
      message: 'Destination created successfully',
      destination
    });
  } catch (error) {
    console.error('Create destination error:', error);
    res.status(500).json({ error: 'Failed to create destination' });
  }
}

// List destinations for a travel
async function listDestinations(req, res) {
  try {
    const { travelId } = req.params;

    // Verify travel exists and belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    const destinations = await Destination.find({ 
      travelId, 
      userId: req.userId 
    });

    res.json({
      destinations,
      total: destinations.length
    });
  } catch (error) {
    console.error('List destinations error:', error);
    res.status(500).json({ error: 'Failed to fetch destinations' });
  }
}

// Get single destination
async function getSingleDestination(req, res) {
  try {
    const { travelId, destId } = req.params;

    // Verify travel exists and belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    const destination = await Destination.findOne({ 
      _id: destId, 
      travelId, 
      userId: req.userId 
    });

    if (!destination) {
      return res.status(404).json({ error: 'Destination not found' });
    }

    res.json({ destination });
  } catch (error) {
    console.error('Get destination error:', error);
    res.status(500).json({ error: 'Failed to fetch destination' });
  }
}

// Update destination
async function updateDestination(req, res) {
  try {
    const { travelId, destId } = req.params;
    const { name, latitude, longitude, notes, visited } = req.body;

    // Verify travel exists and belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    const destination = await Destination.findOne({ 
      _id: destId, 
      travelId, 
      userId: req.userId 
    });

    if (!destination) {
      return res.status(404).json({ error: 'Destination not found' });
    }

    // Update fields
    if (name !== undefined) destination.name = name;
    if (latitude !== undefined) destination.latitude = latitude;
    if (longitude !== undefined) destination.longitude = longitude;
    if (notes !== undefined) destination.notes = notes;
    if (visited !== undefined) destination.visited = visited;

    await destination.save();

    res.json({
      message: 'Destination updated successfully',
      destination
    });
  } catch (error) {
    console.error('Update destination error:', error);
    res.status(500).json({ error: 'Failed to update destination' });
  }
}

// Delete destination
async function deleteDestination(req, res) {
  try {
    const { travelId, destId } = req.params;

    // Verify travel exists and belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId: req.userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    const destination = await Destination.findOne({ 
      _id: destId, 
      travelId, 
      userId: req.userId 
    });

    if (!destination) {
      return res.status(404).json({ error: 'Destination not found' });
    }

    await Destination.deleteOne({ _id: destId });

    res.json({ message: 'Destination deleted successfully' });
  } catch (error) {
    console.error('Delete destination error:', error);
    res.status(500).json({ error: 'Failed to delete destination' });
  }
}

module.exports = {
  createDestination,
  listDestinations,
  getSingleDestination,
  updateDestination,
  deleteDestination
};
