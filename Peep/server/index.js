var app = require('http').createServer();

app.listen('8000', function() {
	console.log('listening on localhost:8000');
});

var io = require('socket.io')(app);

var mongoose = require('mongoose');

var numConnectedClients = 0;

mongoose.connect('mongodb://localhost/PeepTestData', function(err) {
	if(err) {
		console.log(err);
	}
	else {
		console.log('connected to db PeepTestData');
	}
});

var postSchema = mongoose.Schema({
	content: String,
	timeCreated: {type: Date, default: Date.now}
});

var Model = mongoose.model('Post', postSchema);

io.on('connection', function(socket) {
	numConnectedClients++;
	console.log(numConnectedClients + ' clients connected');

	var query = Model.find({});

	query.sort('-timeCreated').limit(10).exec(function(err, docs) {
		if(err) {
			throw err;
		}

		console.log('loading posts');

		socket.emit('loadPosts', docs);

	});

	socket.on('disconnect', function() {
		numConnectedClients--;
		console.log(numConnectedClients + ' clients connected');
	});

	socket.on('createPost', function(pst) {
		var newPost = new Model({content: pst});

		newPost.save(function(err) {
			if(err) {
				throw err;
			}
			else {
				console.log(newPost + ' saved to db!');
			}
		});
	});

	socket.on('reloadPosts', function() {
		var query = Model.find({});

		query.sort('-timeCreated').limit(10).exec(function(err, docs) {
			if(err) {
				throw err;
			}

			console.log('loading posts');

			socket.emit('loadPosts', docs);

		});
	});

});