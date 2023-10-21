// const Sequelize = require('sequelize'); 
// require('dotenv').config();

// const sequelize = new Sequelize(process.env.DB_NAME,process.env.DB_USER,process.env.DB_PASSWORD,{
//     dialect: 'mysql',
//     host:'localhost',
//     port: 3306
// });

// module.exports = sequelize

const sequelize = new Sequelize(
    process.env.DB_DATABASE, 
    process.env.DB_USERNAME, 
    process.env.DB_PASSWORD, 
    {
        host: process.env.DB_HOST,
        dialect: 'mysql',
        port: 3306,
    }
);
module.exports = sequelize