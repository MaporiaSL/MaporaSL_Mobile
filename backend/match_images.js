const fs = require('fs');
const path = require('path');

const jsonPath = path.resolve(__dirname, 'src/data/realStoreSampleProducts.json');
const products = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

const files = [
  "Arugam_Bay_Surfboard.png",
  "Arugam_Bay_Wave_Key_Tag.png",
  "Batticaloa_Lagoon_Bicycle_Postcard.png",
  "Birdwatcher_Sketchbook.png",
  "Casaurina_Coastal_Sand_Bottle.png",
  "Colombo_Lighthouse.png",
  "Dondra_Light_House.png",
  "Galle_Compass_Key.png",
  "Galle_Face_Sunset_Postcard_Set.png",
  "Galle_Fort_Street_Art_Frame.png",
  "Gregory_Lake_Enamel_Mug.png",
  "Iranamadu_Sunset.png",
  "Jaffna_Palm_Pot.png",
  "Kalutara_Bodhuya_Mini_Replica.png",
  "Kalutara_Bridge_Sketch_Notebook.png",
  "Kandy_Perahera_Wooden_Mask.png",
  "Kattankudy_Mosque_Art.png",
  "Kelaniya_Temple_Fridge_Magnet.png",
  "Mannar_Pearls_Pendant.png",
  "Mannar_Tree_Art.png",
  "Matale_Spice_Garden_Sachet_Pack.png",
  "Mullaitivu_Beach_Art_Mug.png",
  "Nalanda_Gedige_Stone_Carving_Replica.png",
  "Nallur_Key_Tag.png",
  "Negombo_Fishing_Keytag.png",
  "Nuwara_Eliya_Tea_Estate_Canvas_Tote.png",
  "Palmayrah_Weave_Bookmark.png",
  "Salt_Pan_Coaster.png",
  "Shell_Bracelet.png",
  "Temple_of_Tooth_Art.png",
  "Vavuniya_Bus_Route_Key.png",
  "Vavuniya_Reservior_Print.png"
];

function sanitize(str) {
  return str.toLowerCase().replace(/[^a-z0-9]/g, '');
}

products.forEach(p => {
  const pName = sanitize(p.name);
  let bestMatch = null;
  let bestScore = -1;

  files.forEach(f => {
    const fName = sanitize(f.replace('.png', '').replace('.jpg', ''));
    if (pName.includes(fName) || fName.includes(pName)) {
      bestMatch = f;
      bestScore = 100;
    } else {
      const pWords = p.name.toLowerCase().split(/[^a-z0-9]+/);
      const fWords = f.toLowerCase().replace('.png', '').split(/[^a-z0-9]+/);
      let score = 0;
      pWords.forEach(w => {
        if (w.length > 2 && fWords.includes(w)) score++;
      });
      if (score > bestScore) {
        bestScore = score;
        bestMatch = f;
      }
    }
  });

  if (bestMatch && bestScore > 0) {
    p.images = [`/uploads/products/${bestMatch}`];
    p.thumbnail = `/uploads/products/${bestMatch}`;
  }
});

fs.writeFileSync(jsonPath, JSON.stringify(products, null, 2));
console.log('Successfully updated the blueprint!');
