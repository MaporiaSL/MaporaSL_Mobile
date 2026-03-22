/**
 * Utility to map Sri Lankan attractions to real public-domain photo URLs
 * and provide high-quality keyword-based placeholders.
 */

const PREDEFINED_PHOTOS = {
    'sigiriya rock fortress': [
        'https://upload.wikimedia.org/wikipedia/commons/4/4c/Sigiriya__Rock_Fortress_Administrative_District_Matale_Sri_Lanka.jpg',
        'https://images.unsplash.com/photo-1546708973-b339540b5162?q=80&w=1000'
    ],
    'temple of the tooth': [
        'https://upload.wikimedia.org/wikipedia/commons/6/6f/Temple_of_the_Tooth_Cradled_Kandy_Sri_Lanka.jpg',
        'https://images.unsplash.com/photo-1588598116142-f831341c529d?q=80&w=1000'
    ],
    'galle fort': [
        'https://upload.wikimedia.org/wikipedia/commons/3/3a/Galle_Fort_Lighthouse_Sri_Lanka.jpg',
        'https://images.unsplash.com/photo-1590635293290-798836528d7a?q=80&w=1000'
    ],
    'ella rock': [
        'https://upload.wikimedia.org/wikipedia/commons/3/3a/Ella_Rock_Viewpoint_Badulla_District_Sri_Lanka.jpg',
        'https://images.unsplash.com/photo-1552423150-14304859037e?q=80&w=1000'
    ],
    'adam\'s peak': [
        'https://upload.wikimedia.org/wikipedia/commons/f/f7/Adams_Peak_Sri_Lanka.jpg'
    ],
    'nine arches bridge': [
        'https://images.unsplash.com/photo-1550928929-28c46006de2f?q=80&w=1000',
        'https://upload.wikimedia.org/wikipedia/commons/4/4b/Nine_Arches_Bridge_Ella_Sri_Lanka.jpg'
    ],
    'yala national park': [
        'https://images.unsplash.com/photo-1582239611681-499924403164?q=80&w=1000',
        'https://upload.wikimedia.org/wikipedia/commons/9/9c/Leopard_at_Yala_National_Park.jpg'
    ],
    'mirissa beach': [
        'https://images.unsplash.com/photo-1586900456254-2c0694084361?q=80&w=1000'
    ],
    'hikkaduwa beach': [
        'https://images.unsplash.com/photo-1586958434358-0062a433989c?q=80&w=1000'
    ],
    'unawatuna beach': [
        'https://images.unsplash.com/photo-1586958434313-0062a433947f?q=80&w=1000'
    ],
    'pinnawala elephant orphanage': [
        'https://upload.wikimedia.org/wikipedia/commons/7/7b/Pinnawala_Elephant_Orphanage_2011.jpg'
    ],
    'dambulla cave temple': [
        'https://upload.wikimedia.org/wikipedia/commons/5/52/Dambulla_Cave_Temple_Buddha_Statues.jpg'
    ]
};

/**
 * Get photos for a place name
 * @param {string} name - The name of the place
 * @param {string} category - The category of the place
 * @returns {string[]} Array of image URLs
 */
function getPhotos(name, category = 'place') {
    const normalized = name.toLowerCase().trim();
    
    // 1. Check if we have predefined real photos
    if (PREDEFINED_PHOTOS[normalized]) {
        return PREDEFINED_PHOTOS[normalized];
    }
    
    // 2. Generate keyword-based placeholders from LoremFlickr
    // This is much more likely to be relevant than random Picsum.
    const keyword = normalized.split(' ').slice(0, 3).join(',');
    const fallbackCategory = category || 'nature,srilanka';
    
    return [
        `https://loremflickr.com/800/600/${encodeURIComponent(normalized.replace(/ /g, ','))},srilanka?random=1`,
        `https://loremflickr.com/800/600/${encodeURIComponent(fallbackCategory)},travel?random=2`,
        `https://loremflickr.com/800/600/${encodeURIComponent(name.split(' ')[0])},view?random=3`
    ];
}

module.exports = { getPhotos };
