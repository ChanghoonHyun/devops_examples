var uuid = require('node-uuid');

exports.index = function(req, res) {
  res.app.get('connection').query( 'SELECT * FROM HIKES', function(err, rows) {
    if (err) {
      res.send(err);
    } else {
      res.send(rows)
  }});
};

exports.add_hike = function(req, res){
  console.log(req.body)
  var hike = { HIKE_DATE: new Date(), ID: uuid.v4(), NAME: req.body.name,
      LOCATION: null, DISTANCE: null, WEATHER: null};

  console.log('Request to log hike:' + JSON.stringify(hike));
  req.app.get('connection').query('INSERT INTO HIKES set ?', hike, function(err) {
    if (err) {
      res.send(err);
    } else {
      res.send({status: 201});
    }
  });
};