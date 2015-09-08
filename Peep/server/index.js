var app = require('http').createServer();

app.listen('8000', function() {
	console.log('listening on localhost:8000');
});

// app.listen(8000, '192.168.1.4', function() {
// 	console.log('listening on 192.168.1.4:8000');
// });

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

// mongoose.connect('mongodb://192.168.1.4/PeepTestData', function(err) {
// 	if(err) {
// 		console.log(err);
// 	}
// 	else {
// 		console.log('connected to db PeepTestData');
// 	}
// });

var postSchema = mongoose.Schema({
	userId: String,
	content: String,
	likes: {type: Number, default: 0},
	hashtags: [String],
	comments: [
		{	
			userId: String,
			content: String,
			likes: Number,
			timeCreated: {type: Date, default: Date.now}
		}
	],
	timeCreated: {type: Date, default: Date.now}
}, {'autoIndex': false});

//postSchema.set('autoIndex', false);

var PostModel = mongoose.model('Post', postSchema);

function loadPosts(socket, post) {
	var query = PostModel.find({});

	query.sort('-timeCreated').limit(100).exec(function(err, docs) {
		if(err) {
			throw err;
		}

		console.log('loading posts');

		socket.emit('loadPosts', docs);
	});
}

function loadMyPosts(socket, postId) {
	var query = PostModel.find({userId: postId});


	query.sort('-timeCreated').limit(100).exec(function(err, docs) {
		if(err) {
			throw err;
		}

		console.log('loading my posts');

		socket.emit('loadMyPosts', docs);
	});
}

function createPost(post) {
	var newPost = new PostModel({userId: post.userId, content: post.content});

		newPost.save(function(err) {
			if(err) {
				throw err;
			}
			else {
				console.log(newPost + ' saved to db!');
			}
		});
}

io.on('connection', function(socket) {
	numConnectedClients++;
	console.log(numConnectedClients + ' clients connected');

	loadPosts(socket);

	socket.on('disconnect', function() {
		numConnectedClients--;
		console.log(numConnectedClients + ' clients connected');
	});

	socket.on('createPost', function(pst) {
		createPost(pst);
	});

	socket.on('reloadPosts', function() {
		loadPosts(socket);
	});

	socket.on('loadMyPosts', function(pstId) {
		loadMyPosts(socket, pstId);		
	});
});