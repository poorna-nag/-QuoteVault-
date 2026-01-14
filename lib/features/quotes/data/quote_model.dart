class Quote {
  final String id, quote, author, category;

  Quote(this.id, this.quote, this.author, this.category);

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(json['id'], json['quote'], json['author'], json['category']);
  }
}
