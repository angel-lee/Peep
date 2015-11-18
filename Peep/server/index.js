var app = require('http').createServer();

// app.listen('8000', function() {
// 	console.log('listening on localhost:8000');
// });

app.listen(8000, '192.168.1.4', function() {
	console.log('listening on 192.168.1.4:8000');
});

var io = require('socket.io')(app);

var mongoose = require('mongoose');

var numConnectedClients = 0;

// mongoose.connect('mongodb://localhost/PeepTestData', function(err) {
// 	if(err) {
// 		console.log(err);
// 	}
// 	else {
// 		console.log('connected to db PeepTestData');
// 	}
// });

mongoose.connect('mongodb://192.168.1.4/PeepTestData', function(err) {
	if(err) {
		console.log(err);
	}
	else {
		console.log('connected to db PeepTestData');
	}
});

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

function createPost(socket, post) {
	var newPost = new PostModel({userId: post.userId, content: post.content, hashtags: post.hashtags});

		newPost.save(function(err) {
			if(err) {
				throw err;
			}
			else {
				console.log(newPost + ' saved to db!');
				//socket.emit('postSaved', newPost);
				loadPosts(socket);
			}
		});
}

function loadPosts(socket) {
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

		if(post.likers.indexOf(thePost.userId) == -1) {
			post.likes++;
			post.likers.push(thePost.userId);
			post.save(function(err) {
				if (err) {
					return handleError(err);
				}
				console.log(post.likers);
				console.log("post now has " + post.likes + " likes");
			});
		}

		else {
			console.log('already liked post');
		}
	});
}

function unlikePost(thePost) {
	PostModel.findById(thePost.postId, function(err, post) {
		if (err) {
			return handleError(err);
		}

		if(post.likers.indexOf(thePost.userId) != -1) {
			post.likes--;
			post.likers.splice(post.likers.indexOf(thePost.userId),1);
			post.save(function(err) {
				if (err) {
				return handleError(err);
				}
				console.log(post.likers);
				console.log("post now has " + post.likes + " likes");
			});
		}

		else {
			console.log('already unliked post');
		}
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
			console.log(post.comments);
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
	var query = PostModel.find({'comments.userId': commentId});

	query.sort('-timeCreated').exec(function(err, posts) {
		if(err) {
			handleError(err);
		}
		console.log('loading posts I\'ve commented on');
		socket.emit('loadMyComments', posts);
	});
}

function likeComment(theComment) {
	PostModel.findById(theComment.postId, function(err, post) {
		if(err) {
			throw err;
		}

		console.log(post.content);
		var subDoc = post.comments.id(theComment.commentId);

		console.log(subDoc.content);

		if(subDoc.likers.indexOf(theComment.userId) == -1) {
			subDoc.likes++;
			subDoc.likers.push(theComment.userId);
			post.save(function(err) {
				if (err) {
				return handleError(err);
				}
				console.log('[' + subDoc.content  + '] now has ' + subDoc.likes + ' likes');
			});
		}

		else {
			console.log('already liked comment');
		}
	});
}

function unlikeComment(theComment) {
	PostModel.findById(theComment.postId, function(err, post) {
		if(err) {
			throw err;
		}

		console.log(post.content);
		var subDoc = post.comments.id(theComment.commentId);

		console.log(subDoc.content);

		if(subDoc.likers.indexOf(theComment.userId) != -1) {
			subDoc.likes--;
			subDoc.likers.splice(subDoc.likers.indexOf(theComment.userId),1);
			post.save(function(err) {
				if (err) {
				return handleError(err);
				}
				console.log('[' + subDoc.content  + '] now has ' + subDoc.likes + ' likes');
			});
		}

		else {
			console.log('already unliked comment');
		}
	});
}

function getThePost(socket, postId) {
	PostModel.findById(postId, function(err, post) {
		if (err) {
			throw err;
		}

		console.log('getting post [' + post.content + ']');
		socket.emit("getThePost", post);
	});

}

function loadPostsWithHashtag(socket, hashtag) {
	var query = PostModel.find({hashtags: hashtag});

	query.sort('-timeCreated').exec(function(err, posts) {
		if(err) {
			throw err;
		}
		console.log('getting posts with hashtag [' + hashtag + ']');
		socket.emit('loadPostsWithHashtag', posts);
	});
}

function filterForHashtags(socket, filter) {
	var allHashtags = [];

	var query = PostModel.find({hashtags: {$regex: '^' + filter}});

	if (filter != "") {
		query.exec(function(err, posts) {
			if (err) {
				throw err;
			}

			for(var i = 0; i < posts.length; i++) {
				for (var j = 0; j < posts[i].hashtags.length; j++) {
					if (posts[i].hashtags[j].indexOf(filter) != -1) {
						if (allHashtags.indexOf(posts[i].hashtags[j]) == -1) {
							allHashtags.push(posts[i].hashtags[j]);
						}
					}
				}
			}
			console.log(allHashtags);
			socket.emit('filterForHashtags', allHashtags);
		});
	}
	else {
		allHashtags = [];
		socket.emit('filterForHashtags', allHashtags);
	}
}

function trendingHashtags(socket) {
	var dayInMilliseconds = 86400000;
	var todayDate = new Date();

	var hashtagArray = [];
	var map = [];
	var multiplier = 1
	//console.log(todayDate);
	//console.log(yesterdayDate);
	var yesterdayDate = new Date(new Date() - (dayInMilliseconds));

	var query = PostModel.find({'timeCreated': {'$gte': yesterdayDate, '$lt': todayDate}});

	query.exec(function(err, posts) {
		if(err) {
			throw err;
		}

		for (var i = 0; i < posts.length; i++) {
			for (var j = 0; j < posts[i].hashtags.length; j++) {
				hashtagArray.push(posts[i].hashtags[j]);
			}
		}

		map = hashtagArray.reduce(function (p, c) {
    		p[c] = (p[c] || 0) + 1;
    		return p;
		}, {});

		console.log(map);

		var newTypesArray = Object.keys(map).sort(function (a, b) {
    		return map[a] < map[b];
		});

		//console.log(newTypesArray);
		//console.log(newTypesArray);
		//console.log('trendingHashtags');
		socket.emit('trendingHashtags', newTypesArray);
	});
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

io.on('connection', function(socket) {
	numConnectedClients++;
	console.log(numConnectedClients + ' clients connected');

	loadPosts(socket);

	socket.on('disconnect', function() {
		numConnectedClients--;
		console.log(numConnectedClients + ' clients connected');
	});

	socket.on('createPost', function(pst) {
		createPost(socket, pst);
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

	socket.on('loadMyComments', function(pstId) {
		loadMyComments(socket, pstId);
	});

	socket.on('likePost', function(pstId) {
		likePost(pstId);
	});
	socket.on('unlikePost', function(pstId) {
		unlikePost(pstId);
	});

	socket.on('likeComment', function(cmtId) {
		likeComment(cmtId);
	});

	socket.on('unlikeComment', function(cmtId) {
		unlikeComment(cmtId);
	});

	socket.on('getThePost', function(pstId) {
		getThePost(socket, pstId);
	});

	socket.on('loadPostsWithHashtag', function(tag) {
		loadPostsWithHashtag(socket, tag);
	});

	socket.on('filterForHashtags', function(filter) {
		filterForHashtags(socket, filter);
	});

	socket.on('trendingHashtags', function() {
		trendingHashtags(socket);
	});
});