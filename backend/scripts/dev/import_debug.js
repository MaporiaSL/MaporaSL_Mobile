try {
    console.log('Testing imports...');

    console.log('1. nodePath/path');
    const nodePath = require('path');
    console.log(' - OK');

    console.log('2. dotenv');
    require('dotenv').config();
    console.log(' - OK');

    console.log('3. express');
    require('express');
    console.log(' - OK');

    console.log('4. cors');
    require('cors');
    console.log(' - OK');

    console.log('5. helmet');
    require('helmet');
    console.log(' - OK');

    console.log('6. morgan');
    require('morgan');
    console.log(' - OK');

    console.log('7. mongoose');
    require('mongoose');
    console.log(' - OK');

    console.log('8. Internal: config/db');
    require('./src/config/db');
    console.log(' - OK');

    console.log('9. Internal: middleware/auth');
    require('./src/middleware/auth');
    console.log(' - OK');

    console.log('10. Internal: routes/authRoutes');
    require('./src/routes/authRoutes');
    console.log(' - OK');

    console.log('11. Internal: routes/placeRoutes');
    require('./src/routes/placeRoutes');
    console.log(' - OK');

    console.log('All critical imports tested successfully.');
} catch (e) {
    console.error('Import failed:', e.message);
    if (e.requireStack) console.log('Stack:', e.requireStack);
    process.exit(1);
}
