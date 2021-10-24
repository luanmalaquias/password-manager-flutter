class Credenciais {
  int? id;
  String? site;
  String? senha;

  Credenciais({this.id, this.site, this.senha});

  Map<String, dynamic> toMap() {
    return {'id': id,'site': site, 'senha': senha};
  }
}
