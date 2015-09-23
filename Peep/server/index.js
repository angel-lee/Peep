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
	likers: [String],
	hashtags: [String],
	comments: [
		{	
			userId: String,
			content: String,
			likes: {type: Number, default: 0},
			likers: [String],
			timeCreated: {type: Date, default: Date.now}
		}
	],
	timeCreated: {type: Date, default: Date.now}
}, {'autoIndex': false});


var PostModel = mongoose.model('Post', postSchema);

function createPost(post) {
	var newPost = new PostModel({userId: post.userId, content: post.content});

		newPost.save(function(err) {
			if(err) {
				throw err;
			}
			else {
				console.log(newPost + ' saved to db!');
				//socket.emit('postSaved', newPost);
			}
		});
}

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

function likePost(thePost) {
	PostModel.findById(thePost.postId, function(err, post) {
		if (err) {
			return handleError(err);
		}
		post.likes++;
		post.likers.push(thePost.userId);
		post.save(function(err) {
			if (err) {
				return handleError(err);
			}
			console.log("post now has " + post.likes + " likes");
		});
	});
}

function unlikePost(thePost) {
	PostModel.findById(thePost.postId, function(err, post) {
		if (err) {
			return handleError(err);
		}
		post.likes--;
		post.likers.pop(thePost.postId);
		post.save(function(err) {
			if (err) {
				return handleError(err);
			}
			console.log("post now has " + post.likes + " likes");
		});
	});
}

function createComment(socket, theComment) {
	PostModel.findById(theComment.postId, function(err, post) {
		if(err) {
			return handleError(err);
		}

		var newComment = {userId: theComment.userId,
						content: theComment.content};

		post.comments.push(newComment);

		post.save(function(err) {
			if(err) {
				return handleError(err);
			}
			console.log('comment saved to post ' + '[' + post.content + ']');
			socket.emit('commentSaved', post.comments);
		});

	});
}

function loadComments(socket, postId) {
	PostModel.findById(postId, function(err, post) {
		if(err) {
			return handleError(err);
		}
		console.log('loading comments for post ' + '[' + post.content + ']');
		socket.emit('loadComments', post.comments);
	});
}

function loadMyComments(socket, commentId) {
	
}

function likeComment(theComment) {

}

function unlikeComment(theComment) {
	
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

	socket.on('createComment', function(post) {
		createComment(socket, post);
	});

	socket.on('reloadPosts', function() {
		loadPosts(socket);
	});

	socket.on('loadMyPosts', function(pstId) {
		loadMyPosts(socket, pstId);		
	});

	socket.on('loadComments', function(pstId) {
		loadComments(socket, pstId);
	});

	socket.on('likePost', function(pstId) {
		likePost(pstId);
	});
	socket.on('unlikePost', function(pstId) {
		unlikePost(pstId);
	});
});