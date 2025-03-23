class ArticleContentModel {
  ArticleContentModel({
    this.paraType,
    this.text,
    this.format,
    this.line,
  });
  int? paraType;
  Text? text;
  Format? format;
  Line? line;
  Pic? pic;

  ArticleContentModel.fromJson(Map<String, dynamic> json) {
    paraType = json['para_type'];
    text = json['text'] == null ? null : Text.fromJson(json['text']);
    format = json['format'] == null ? null : Format.fromJson(json['format']);
    line = json['line'] == null ? null : Line.fromJson(json['line']);
    pic = json['pic'] == null ? null : Pic.fromJson(json['pic']);
  }
}

class Pic {
  Pic({
    this.url,
    this.width,
    this.height,
    this.size,
    this.pics,
    this.style,
  });
  String? url;
  int? width;
  int? height;
  double? size;
  List<Pic>? pics;
  int? style;

  Pic.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    size = json['size'];
    pics = (json['pics'] as List<dynamic>?)
        ?.map((item) => Pic.fromJson(item))
        .toList();
    style = json['style'];
  }
}

class Line {
  Line({
    this.pic,
  });
  Pic? pic;

  Line.fromJson(Map<String, dynamic> json) {
    pic = json['pic'] == null ? null : Pic.fromJson(json['pic']);
  }
}

class Format {
  Format({
    this.align,
  });
  int? align;

  Format.fromJson(Map<String, dynamic> json) {
    align = json['align'];
  }
}

class Text {
  Text({
    this.nodes,
  });
  List<Nodes>? nodes;

  Text.fromJson(Map<String, dynamic> json) {
    nodes = (json['nodes'] as List<dynamic>?)
        ?.map((item) => Nodes.fromJson(item))
        .toList();
  }
}

class Nodes {
  Nodes({
    this.nodeType,
    this.word,
  });
  int? nodeType;
  Word? word;

  Nodes.fromJson(Map<String, dynamic> json) {
    nodeType = json['node_type'];
    word = json['word'] == null ? null : Word.fromJson(json['word']);
  }
}

class Word {
  Word({
    this.words,
    this.fontSize,
    this.style,
    this.color,
  });
  String? words;
  int? fontSize;
  Style? style;
  String? color;

  Word.fromJson(Map<String, dynamic> json) {
    words = json['words'];
    fontSize = json['font_size'];
    style = json['style'] == null ? null : Style.fromJson(json['style']);
    color = json['color'];
  }
}

class Style {
  Style({
    this.bold,
    this.italic,
    this.strikethrough,
  });
  bool? bold;
  bool? italic;
  bool? strikethrough;

  Style.fromJson(Map<String, dynamic> json) {
    bold = json['bold'];
    italic = json['italic'];
    strikethrough = json['strikethrough'];
  }
}

// class ArticleContentModel {
//   ArticleContentModel({
//     this.attributes,
//     this.insert,
//   });
//   Attributes? attributes;
//   dynamic insert;

//   ArticleContentModel.fromJson(Map<String, dynamic> json) {
//     attributes = json['attributes'] == null
//         ? null
//         : Attributes.fromJson(json['attributes']);
//     insert = json['insert'] == null
//         ? null
//         : json['attributes']?['class'] == 'normal-img'
//             ? Insert.fromJson(json['insert'])
//             : json['insert'];
//   }
// }

// class Insert {
//   Insert({
//     this.nativeImage,
//   });
//   NativeImage? nativeImage;

//   Insert.fromJson(Map<String, dynamic> json) {
//     nativeImage = json['native-image'] == null
//         ? null
//         : NativeImage.fromJson(json['native-image']);
//   }
// }

// class NativeImage {
//   NativeImage({
//     this.alt,
//     this.url,
//     this.width,
//     this.height,
//     this.size,
//     this.status,
//   });

//   dynamic alt;
//   dynamic url;
//   dynamic width;
//   dynamic height;
//   dynamic size;
//   dynamic status;

//   NativeImage.fromJson(Map<String, dynamic> json) {
//     alt = json['alt'];
//     url = json['url'];
//     width = json['width'];
//     height = json['height'];
//     size = json['size'];
//     status = json['status'];
//   }
// }

// class Attributes {
//   Attributes({
//     this.clazz,
//     this.bold,
//     this.color,
//     this.italic,
//     this.strike,
//   });
//   String? clazz;
//   bool? bold;
//   String? color;
//   bool? italic;
//   bool? strike;

//   Attributes.fromJson(Map<String, dynamic> json) {
//     clazz = json['class'];
//     bold = json['bold'];
//     color = json['color'];
//     italic = json['italic'];
//     strike = json['strike'];
//   }
// }
