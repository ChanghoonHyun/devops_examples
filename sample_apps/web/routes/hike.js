const request = require('request')

exports.index = (req, res) => {
  request.get(process.env.API_SERVER + '/hikes', (err, rr) => {
    console.log('error', err)
    console.log(rr.body)
    if (err) {
      res.send(err);
    } else {
      res.render('hike', { title: 'My Hiking Log', hikes: JSON.parse(rr.body) });
    }
  })
}

exports.add_hike = (req, res) => {
  request.post({
    uri: process.env.API_SERVER + '/add_hike',
    form: {
      name: req.body.hike.NAME
    }
  }, (err, rr) => {
    if (err) {
      res.send(err);
    } else {
      res.redirect('/hikes');
    }
  })
}