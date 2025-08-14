const { DataTypes } = require('sequelize');
const sequelize = require('./index');

const Post = sequelize.define('Post', {
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    content: {
        type: DataTypes.TEXT,
        allowNull: false
    }
}, {
    tableName: 'posts',
    timestamps: true, 
});

module.exports = Post;
