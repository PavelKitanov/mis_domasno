class Post {
  String? key;
  PostData? postData;

  Post({this.key, this.postData});
}

class PostData {
  String? restaurantKey;
  String? postUrl;

  PostData(
      {required this.restaurantKey,
       required this.postUrl});

  PostData.fromJson(Map<dynamic, dynamic> json) {
    restaurantKey = json['restaurantKey'];
    postUrl = json['postUrl'];
  }

   Map<String, dynamic> toJson() => {
    "restaurantKey": restaurantKey,
    "postUrl": postUrl,
  };
}