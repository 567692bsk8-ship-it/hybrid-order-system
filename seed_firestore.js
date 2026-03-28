const admin = require('firebase-admin');

// Initialize with project ID
admin.initializeApp({
  projectId: 'hybrid-order-system'
});

const db = admin.firestore();

// 豊富なメニューデータ (醤油, 味噌, 塩, つけ麺, サイド, ドリンク)
const menus = [
  // ラーメン - 醤油
  {id: 'r_shoyu_1', category: 'ラーメン', subCategory: '醤油', name: '特製醤油ラーメン', description: '鶏ガラと魚介のコク深い王道醤油。', basePrice: 880, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'r_shoyu_2', category: 'ラーメン', subCategory: '醤油', name: '醤油チャーシュー麺', description: '厚切りチャーシューが5枚乗った満足の一杯。', basePrice: 1180, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'r_shoyu_3', category: 'ラーメン', subCategory: '醤油', name: '味玉醤油ラーメン', description: 'とろ〜り半熟の味付け玉子をトッピング。', basePrice: 980, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  
  // ラーメン - 味噌
  {id: 'r_miso_1', category: 'ラーメン', subCategory: '味噌', name: '濃厚芳醇味噌ラーメン', description: '三種の味噌をブレンドした濃厚な味わい。', basePrice: 950, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'r_miso_2', category: 'ラーメン', subCategory: '味噌', name: '辛味噌ラーメン', description: '自家製ラー油の刺激が食欲をそそる。', basePrice: 1050, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'r_miso_3', category: 'ラーメン', subCategory: '味噌', name: '特製噌バターコーン', description: '味噌のコクを引き立てる背徳のトッピング。', basePrice: 1150, imageUrl: 'assets/images/ramen.png', isAvailable: true},

  // ラーメン - 塩
  {id: 'r_shio_1', category: 'ラーメン', subCategory: '塩', name: '淡麗ゆず塩ラーメン', description: 'ゆずが香る透明感のある黄金スープ。', basePrice: 850, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'r_shio_2', category: 'ラーメン', subCategory: '塩', name: '海鮮塩バターラーメン', description: '海の幸の旨みが溶け出した贅沢な一杯。', basePrice: 1080, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'r_shio_3', category: 'ラーメン', subCategory: '塩', name: 'ネギ塩ラーメン', description: 'シャキシャキの白髪ネギがたっぷりと。', basePrice: 950, imageUrl: 'assets/images/ramen.png', isAvailable: true},

  // つけ麺
  {id: 't_1', category: 'つけ麺', subCategory: '濃厚', name: '極太魚介つけ麺', description: '超濃厚な魚介豚骨スープと全粒粉麺。', basePrice: 980, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 't_2', category: 'つけ麺', subCategory: '油そば', name: '特製油そば', description: '醤油ベースの特製タレとラー油、お酢で。', basePrice: 850, imageUrl: 'assets/images/ramen.png', isAvailable: true},

  // サイド
  {id: 's_1', category: 'サイド', subCategory: '揚げ物', name: '手包み羽根つき餃子', description: '外はパリッと中は肉汁溢れる看板サイド。', basePrice: 450, imageUrl: 'assets/images/gyoza.png', isAvailable: true},
  {id: 's_2', category: 'サイド', subCategory: '揚げ物', name: 'ジューシー唐揚げ', description: '秘伝のタレに漬け込んだ大ぶりな唐揚げ。', basePrice: 580, imageUrl: 'assets/images/gyoza.png', isAvailable: true},

  // ドリンク
  {id: 'd_1', category: 'ドリンク', subCategory: 'ソフトドリンク', name: 'コーラ', description: 'キンキンに冷えたコカ・コーラ。', basePrice: 250, imageUrl: 'assets/images/ramen.png', isAvailable: true},
  {id: 'd_2', category: 'ドリンク', subCategory: 'アルコール', name: 'プレミアム生ビール', description: '厳選された麦芽100%の極上生。', basePrice: 550, imageUrl: 'assets/images/ramen.png', isAvailable: true},
];

async function seed() {
  const batch = db.batch();
  const collection = db.collection('menus');
  
  console.log('Seeding menus to Firestore...');
  
  menus.forEach(menu => {
    const ref = collection.doc(menu.id);
    batch.set(ref, menu);
  });
  
  await batch.commit();
  console.log('Successfully seeded all menu items!');
}

seed().catch(err => {
  console.error('Seed failed:', err);
  process.exit(1);
});
