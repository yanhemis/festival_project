const { DataTypes } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASSWORD,
    {
        ##process.env.DB_HOST 가 아니라 env.process.DB_HOST가 맞는지 확인##
        host : env.process.DB_HOST,
        dialect : "mysql",
        port : process.env.DB_PORT
    }
);

module.exports = sequelize;
