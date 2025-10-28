const User = require('../models/User');
const Role = require('../models/Role');
const Category = require('../models/Category');
const Channel = require('../models/Channel');

async function initializeDatabase() {
  try {
    // ロールの初期化
    const roles = ['管理者', 'メンバー', 'ビジター'];
    
    for (const roleName of roles) {
      const existingRole = await Role.findOne({ name: roleName });
      if (!existingRole) {
        await Role.create({
          name: roleName,
          description: `${roleName}ロール`,
          permissions: []
        });
        console.log(`ロール「${roleName}」を作成しました`);
      }
    }

    // 初期管理者ユーザーの作成
    const adminEmail = 'kairidaiho12@gmail.com';
    const existingAdmin = await User.findOne({ email: adminEmail });
    
    if (!existingAdmin) {
      const adminRole = await Role.findOne({ name: '管理者' });
      const memberRole = await Role.findOne({ name: 'メンバー' });
      
      const admin = new User({
        email: adminEmail,
        password: 'kairi0986',
        username: 'Kairi',
        roles: [adminRole._id, memberRole._id]
      });
      
      await admin.save();
      console.log('初期管理者ユーザー「Kairi」を作成しました');
    }

    // デフォルトカテゴリの作成
    const defaultCategories = [
      { name: 'お知らせ', description: '重要なお知らせ', order: 1 },
      { name: '雑談', description: '自由な雑談スペース', order: 2 },
      { name: '学習', description: '学習に関する話題', order: 3 }
    ];

    for (const categoryData of defaultCategories) {
      const existingCategory = await Category.findOne({ name: categoryData.name });
      if (!existingCategory) {
        const category = await Category.create(categoryData);
        console.log(`カテゴリ「${categoryData.name}」を作成しました`);

        // デフォルトチャンネルの作成
        if (categoryData.name === 'お知らせ') {
          const allRoles = await Role.find();
          const memberAndAdminRoles = await Role.find({ name: { $in: ['管理者', 'メンバー'] } });
          const adminRole = await Role.find({ name: '管理者' });

          await Channel.create({
            name: '全体お知らせ',
            description: '全体向けのお知らせ',
            category: category._id,
            viewPermissions: allRoles.map(r => r._id),
            postPermissions: adminRole.map(r => r._id),
            order: 1
          });
          console.log('チャンネル「全体お知らせ」を作成しました');
        }

        if (categoryData.name === '雑談') {
          const memberAndAdminRoles = await Role.find({ name: { $in: ['管理者', 'メンバー'] } });

          await Channel.create({
            name: '自由雑談',
            description: 'メンバー同士の自由な雑談',
            category: category._id,
            viewPermissions: memberAndAdminRoles.map(r => r._id),
            postPermissions: memberAndAdminRoles.map(r => r._id),
            order: 1
          });
          console.log('チャンネル「自由雑談」を作成しました');
        }
      }
    }

    console.log('データベースの初期化が完了しました');
  } catch (error) {
    console.error('データベース初期化エラー:', error);
  }
}

module.exports = initializeDatabase;

