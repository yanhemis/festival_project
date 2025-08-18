const { DataTypes } = require('sequelize');
const sequelize = require('./index');

const PostTag = sequelize.define('PostTag', {
  PostId: {
    type: DataTypes.BIGINT.UNSIGNED,
    allowNull: false,
  },
  TagId: {
    type: DataTypes.BIGINT.UNSIGNED,
    allowNull: false,
  },
}, {
  tableName: 'post_tags',
  timestamps: false,
  indexes: [
    { fields: ['PostId'] },
    { fields: ['TagId'] },
    { unique: true, fields: ['PostId', 'TagId'] },
  ],
});
