class Accept {
  final int quality;
  final String format;
  final String description;
  final String codecs;

  Accept({
    required this.quality,
    required this.format,
    required this.description,
    required this.codecs,
  });

  factory Accept.fromJson(Map<String, dynamic> json) {
    return Accept(
      quality: json['quality'] as int,
      format: json['format'] as String,
      description: json['description'] as String,
      codecs: json['codecs'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'format': format,
      'description': description,
      'codecs': codecs,
    };
  }
} 