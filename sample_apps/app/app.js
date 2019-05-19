require('dotenv').config();

var express = require('express')
  , routes = require('./routes')
  , hike = require('./routes/hike')
  , http = require('http')
  , path = require('path')
  , mysql = require('mysql')
  , async = require('async');

var app = express();

app.configure(function () {
  app.set('port', process.env.PORT || 3000);
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
});

app.set('connection', mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT
}));

function init() {
  app.get('/', routes.index);
  app.get('/hikes', hike.index);
  app.post('/add_hike', hike.add_hike);

  http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
  });
}

console.log('start init')
console.log({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT
})
var client = app.get('connection');
async.series([
  function connect(callback) {
    console.log('connect')
    client.connect(callback);
  },
  function clear(callback) {
    console.log('clear')
    client.query('DROP DATABASE IF EXISTS mynode_db', callback);
  },
  function create_db(callback) {
    console.log('create db')
    client.query('CREATE DATABASE mynode_db', callback);
  },
  function use_db(callback) {
    console.log('use db')
    client.query('USE mynode_db', callback);
  },
  function create_table(callback) {
    console.log('create table')
    client.query('CREATE TABLE HIKES (' +
      'ID VARCHAR(40), ' +
      'HIKE_DATE DATE, ' +
      'NAME VARCHAR(40), ' +
      'DISTANCE VARCHAR(40), ' +
      'LOCATION VARCHAR(40), ' +
      'WEATHER VARCHAR(40), ' +
      'PRIMARY KEY(ID))', callback);
  },
  function insert_default(callback) {
    var hike = {
      HIKE_DATE: new Date(), NAME: 'Hazard Stevens',
      LOCATION: 'Mt Rainier', DISTANCE: '4,027m vertical', WEATHER: 'Bad'
    };
    client.query("INSERT INTO `HIKES` (`ID`, `NAME`) VALUES ('12', 'test1');", callback);
  }
], function (err, results) {
  if (err) {
    console.log('Exception initializing database.');
    throw err;
  } else {
    console.log('Database initialization complete.');
    init();
  }
});