const { MongoClient } = require('mongodb');

async function restore() {
  const uri = 'mongodb+srv://maporia_admin:maporiaT34@maporiacluster.wp5hsih.mongodb.net/gemified-travel?retryWrites=true&w=majority&appName=MaporiaCluster';
  const client = new MongoClient(uri);
  const activeUserId = 'xFGv7GJG4yVJsdUE6irCodE7kR02';

  try {
    console.log('🔌 Connecting to MongoDB...');
    await client.connect();
    const db = client.db('gemified-travel');
    console.log('✅ Connected.');

    const now = new Date();

    // 1. Restore Travels
    console.log('🌱 Restoring trips...');
    const travelsColl = db.collection('travels');
    // Clear first to be sure
    await travelsColl.deleteMany({ userId: activeUserId });
    
    await travelsColl.insertMany([
      {
        userId: activeUserId,
        title: 'Southern Heritage Road Trip',
        description: 'Exploring history and beaches of the Southern Province.',
        startDate: new Date(now.getTime() - 45 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 40 * 24 * 60 * 60 * 1000),
        status: 'completed',
        locations: [{ name: 'Galle Fort', day: 1 }, { name: 'Matara Fort', day: 3 }],
        createdAt: now,
        updatedAt: now
      },
       {
        userId: activeUserId,
        title: 'Highlands Mist Adventure',
        description: 'Scaling peaks and chasing waterfalls in Ella.',
        startDate: now,
        endDate: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000),
        status: 'active',
        locations: [{ name: 'Nine Arch Bridge', day: 1 }],
        createdAt: now,
        updatedAt: now
      }
    ]);

    // 2. Restore Achievements in User document
    console.log('🏆 Restoring achievements...');
    const usersColl = db.collection('users');
    await usersColl.updateOne(
      { auth0Id: activeUserId },
      { 
        $set: { 
          achievements: [
            { districtId: 'Colombo', progress: 100, unlockedAt: new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000) },
            { districtId: 'Galle', progress: 100, unlockedAt: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000) }
          ]
        } 
      }
    );

    console.log('🎉 Restoration SUCCESSFUL!');
  } catch (e) {
    console.error('❌ Error:', e);
  } finally {
    await client.close();
    process.exit(0);
  }
}

restore();
