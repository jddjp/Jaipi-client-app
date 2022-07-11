class ImageModel {
  String path;
  String url;

  ImageModel({
    this.path,
    this.url
  });

  ImageModel.fromJSON(Map<String,dynamic> json) {
    try {
      path = json['path'];
      url = json['url'];
    } catch (e) {
      print("ImageModel: Error");
      print(e);
    }
  }
}