const { DataTypes } = require("sequelize");
const sequelize = require("../database");

const Tag = sequelize.define("Tag", {
  name: {
    type: DataTypes.STRING,
    unique: true
  }
});

module.exports = Tag;
